import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoDraft {
  const PhotoDraft({
    required this.path,
    required this.createdAt,
    this.caption = '',
  });
  final String path, caption;
  final DateTime createdAt;
  PhotoDraft withCaption(String text) =>
      PhotoDraft(path: path, createdAt: createdAt, caption: text);
}

abstract interface class DraftRepository {
  Future<PhotoDraft?> read();
  Future<PhotoDraft> importPhoto(String source);
  Future<void> save(PhotoDraft draft);
  Future<void> delete();
}

/// One private, unpublished draft. Replacement commits metadata before removing
/// the previous photo. No gallery originals are ever deleted.
class LocalDraftRepository implements DraftRepository {
  LocalDraftRepository({this.directory});
  final Directory? directory;
  Future<Directory> _root() async {
    final base = directory ?? await getApplicationSupportDirectory();
    return Directory('${base.path}/drafts').create(recursive: true);
  }

  Future<File> _index() async => File('${(await _root()).path}/draft.json');
  @override
  Future<PhotoDraft?> read() async {
    final index = await _index();
    if (!await index.exists()) return null;
    final data = jsonDecode(await index.readAsString()) as Map<String, dynamic>;
    final name = data['file'] as String;
    if (!RegExp(r'^photo-[0-9]+\.[a-zA-Z0-9]+$').hasMatch(name)) {
      throw const FormatException('Invalid draft path');
    }
    final photo = File('${(await _root()).path}/$name');
    if (!await photo.exists()) {
      throw const FileSystemException('Draft photo missing');
    }
    return PhotoDraft(
      path: photo.path,
      createdAt: DateTime.parse(data['createdAt'] as String),
      caption: data['caption'] as String,
    );
  }

  @override
  Future<PhotoDraft> importPhoto(String source) async {
    final old = await read();
    final root = await _root();
    final suffix = source.split('.').last;
    final ext = RegExp(r'^[a-zA-Z0-9]{1,5}$').hasMatch(suffix) ? suffix : 'jpg';
    final path =
        '${root.path}/photo-${DateTime.now().microsecondsSinceEpoch}.$ext';
    final file = await File(source).copy(path);
    final next = PhotoDraft(path: file.path, createdAt: DateTime.now().toUtc());
    try {
      await save(next);
    } catch (_) {
      await file.delete();
      rethrow;
    }
    if (old != null) {
      try {
        await File(old.path).delete();
      } on FileSystemException {
        /* Safe orphan; never invalidate a committed draft. */
      }
    }
    return next;
  }

  @override
  Future<void> save(PhotoDraft draft) async {
    final root = await _root();
    if (File(draft.path).parent.absolute.path != root.absolute.path) {
      throw const FormatException('Draft outside private storage');
    }
    final index = await _index();
    final temp = File('${index.path}.tmp');
    await temp.writeAsString(
      jsonEncode({
        'file': draft.path.split(RegExp(r'[/\\]')).last,
        'createdAt': draft.createdAt.toIso8601String(),
        'caption': draft.caption,
      }),
      flush: true,
    );
    await temp.rename(index.path);
  }

  @override
  Future<void> delete() async {
    final draft = await read();
    final index = await _index();
    if (draft != null) {
      // Remove metadata first; retry can safely clean up a remaining orphan.
      await index.delete();
      try {
        await File(draft.path).delete();
      } catch (_) {
        await save(draft);
        rethrow;
      }
    }
  }
}
