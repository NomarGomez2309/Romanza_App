// Explicit development entry point: no Firebase, accounts or network content.
import 'package:flutter/material.dart';
import 'app.dart';
import 'features/auth/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RomanzaApp(initialize: () async {}, authRepository: _PreviewAuth()));
}

// This development-only entry point cannot authenticate or read remote data.
class _PreviewAuth implements AuthRepository {
  @override
  AuthIdentity get current =>
      const AuthIdentity(uid: 'visual-preview', verified: true);
  @override
  Stream<AuthIdentity?> get changes => Stream.value(current);
  @override
  Future<void> ensureProfile() async {}
  @override
  Future<void> login(String email, String password) async =>
      throw UnsupportedError('Visual preview');
  @override
  Future<void> register(String email, String password) async =>
      throw UnsupportedError('Visual preview');
  @override
  Future<void> google() async => throw UnsupportedError('Visual preview');
  @override
  Future<void> resetPassword(String email) async =>
      throw UnsupportedError('Visual preview');
  @override
  Future<void> sendVerification() async =>
      throw UnsupportedError('Visual preview');
  @override
  Future<void> refresh() async {}
  @override
  Future<void> signOut() async {}
}
