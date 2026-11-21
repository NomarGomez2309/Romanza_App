import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.coupleId,
    this.partnerId,
    this.activeInviteId,
    this.acceptedTermsVersion,
    this.skipped = false,
    this.fromCache = false,
  });
  final String uid;
  final String displayName;
  final String? coupleId;
  final String? partnerId;
  final String? activeInviteId;
  final String? acceptedTermsVersion;
  final bool skipped;
  final bool fromCache;
}

class LegalDocuments {
  const LegalDocuments({
    required this.version,
    required this.termsUrl,
    required this.privacyUrl,
  });
  final String version;
  final String termsUrl;
  final String privacyUrl;
  bool get valid =>
      RegExp(r'^[A-Za-z0-9._-]{1,128}$').hasMatch(version) &&
      [termsUrl, privacyUrl].every(
        (url) =>
            Uri.tryParse(url)?.scheme == 'https' &&
            (Uri.tryParse(url)?.host.isNotEmpty ?? false),
      );
}

abstract interface class SessionData {
  Future<void> ensureProfile(String uid);
  Stream<UserProfile?> watchProfile(String uid);
  Stream<LegalDocuments?> watchLegal();
}

class ProfileRepository implements SessionData {
  ProfileRepository({FirebaseFirestore? db, FirebaseFunctions? functions})
    : _db = db ?? FirebaseFirestore.instance,
      _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  @override
  Future<void> ensureProfile(String uid) async {
    // Existing users can enter with cached data without an online transaction.
    try {
      final cached = await _db
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        _checkSchema(cached.data()!, uid);
        return;
      }
    } on FirebaseException catch (error) {
      if (!['unavailable', 'not-found'].contains(error.code)) rethrow;
    }
    await _db.runTransaction((tx) async {
      final ref = _db.collection('users').doc(uid);
      final snap = await tx.get(ref);
      if (snap.exists) {
        _checkSchema(snap.data()!, uid);
        return;
      }
      tx.set(ref, {
        'uid': uid,
        'displayName': '',
        'theme': 'Default',
        'language': 'system',
        'onboardingSkipped': false,
        'coupleId': null,
        'partnerId': null,
        'activeInviteId': null,
        'acceptedTermsVersion': null,
        'acceptedTermsAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void _checkSchema(Map<String, dynamic> data, String uid) {
    const fields = {
      'uid',
      'displayName',
      'theme',
      'language',
      'onboardingSkipped',
      'createdAt',
      'updatedAt',
      'coupleId',
      'partnerId',
      'activeInviteId',
      'acceptedTermsVersion',
      'acceptedTermsAt',
    };
    if (data['uid'] != uid ||
        data['displayName'] is! String ||
        data.keys.toSet().difference(fields).isNotEmpty ||
        fields.difference(data.keys.toSet()).isNotEmpty) {
      throw StateError(
        'Este perfil anterior necesita una migración antes de continuar.',
      );
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots(includeMetadataChanges: true)
      .map((snap) {
        final p = snap.data();
        if (p == null) return null;
        return UserProfile(
          uid: uid,
          displayName: p['displayName'] as String? ?? '',
          coupleId: p['coupleId'] as String?,
          partnerId: p['partnerId'] as String?,
          activeInviteId: p['activeInviteId'] as String?,
          acceptedTermsVersion: p['acceptedTermsVersion'] as String?,
          skipped: p['onboardingSkipped'] == true,
          fromCache: snap.metadata.isFromCache,
        );
      });
  @override
  Stream<LegalDocuments?> watchLegal() =>
      _db.doc('legal/current').snapshots().map((snap) {
        final d = snap.data();
        if (d == null) return null;
        return LegalDocuments(
          version: d['version'] as String? ?? '',
          termsUrl: d['termsUrl'] as String? ?? '',
          privacyUrl: d['privacyUrl'] as String? ?? '',
        );
      });
  Future<void> saveName(String uid, String name) {
    final value = name.trim();
    if (value.isEmpty || value.length > 60) {
      throw StateError('Escribe un nombre de 1 a 60 caracteres.');
    }
    return _db.doc('users/$uid').update({
      'displayName': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> skipPairing(String uid) => _db.doc('users/$uid').update({
    'onboardingSkipped': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  Future<void> acceptTerms(String version) async {
    await _functions.httpsCallable('acceptTerms').call({
      'version': version,
      'accepted': true,
    });
  }
}
