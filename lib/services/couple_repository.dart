import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CoupleRepository {
  CoupleRepository({FirebaseFunctions? functions, FirebaseFirestore? db})
    : _functions = functions ?? FirebaseFunctions.instance,
      _db = db ?? FirebaseFirestore.instance;
  final FirebaseFunctions _functions;
  final FirebaseFirestore _db;
  Future<Map<String, dynamic>> _call(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    final result = await _functions
        .httpsCallable(
          name,
          options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
        )
        .call(data ?? {});
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<Map<String, dynamic>> createInvite() => _call('createInvite');
  Future<Map<String, dynamic>> preview(String token) =>
      _call('previewInvite', {'token': token.trim()});
  Future<void> request(String token) async {
    await _call('requestInvite', {'token': token.trim()});
  }

  Future<void> confirm(String inviteId) async {
    await _call('confirmInvite', {'inviteId': inviteId});
  }

  Future<void> revoke(String inviteId) async {
    await _call('revokeInvite', {'inviteId': inviteId});
  }

  Future<void> unlink() async {
    await _call('unlinkCouple', {'confirmed': true});
  }

  Stream<Map<String, dynamic>?> watchInvite(String id) =>
      _db.doc('invites/$id').snapshots().map((s) => s.data());
  Stream<Map<String, dynamic>?> watchCouple(String id) =>
      _db.doc('couples/$id').snapshots().map((s) => s.data());
}
