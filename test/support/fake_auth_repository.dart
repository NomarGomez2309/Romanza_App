import 'dart:async';
import 'package:romanza/features/auth/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.user = const AuthIdentity(
      uid: 'test-user',
      verified: true,
      email: 'test@example.invalid',
    ),
  });
  AuthIdentity? user;
  final events = StreamController<AuthIdentity?>.broadcast(sync: true);
  AuthFailure? failure, refreshFailure, profileFailure;
  Completer<void>? pending;
  int loginCalls = 0, profileCalls = 0, verificationCalls = 0;
  String? lastPassword;
  @override
  AuthIdentity? get current => user;
  @override
  Stream<AuthIdentity?> get changes => Stream.multi((sink) {
    sink.add(user);
    final subscription = events.stream.listen(sink.add, onError: sink.addError);
    sink.onCancel = subscription.cancel;
  });
  void emit(AuthIdentity? next) {
    user = next;
    events.add(next);
  }

  @override
  Future<void> login(String email, String password) async {
    loginCalls++;
    lastPassword = password;
    await pending?.future;
    if (failure != null) throw failure!;
    emit(AuthIdentity(uid: 'new-user', email: email.trim(), verified: false));
  }

  @override
  Future<void> register(String email, String password) =>
      login(email, password);
  @override
  Future<void> google() async {
    if (failure != null) throw failure!;
    emit(const AuthIdentity(uid: 'google-user', verified: true));
  }

  @override
  Future<void> resetPassword(String email) async {
    if (failure != null) throw failure!;
  }

  @override
  Future<void> sendVerification() async {
    verificationCalls++;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> refresh() async {
    if (refreshFailure != null) throw refreshFailure!;
  }

  @override
  Future<void> ensureProfile() async {
    profileCalls++;
    if (profileFailure != null) throw profileFailure!;
  }

  @override
  Future<void> signOut() async {
    if (failure != null) throw failure!;
    emit(null);
  }
}
