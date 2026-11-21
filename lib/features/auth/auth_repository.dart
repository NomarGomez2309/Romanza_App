import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class AuthIdentity {
  const AuthIdentity({required this.uid, required this.verified, this.email});
  final String uid;
  final String? email;
  final bool verified;
}

class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);
  final String code, message;
}

abstract interface class AuthRepository {
  Stream<AuthIdentity?> get changes;
  AuthIdentity? get current;
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> google();
  Future<void> resetPassword(String email);
  Future<void> sendVerification();
  Future<void> refresh();
  Future<void> ensureProfile();
  Future<void> signOut();
}

/// Firebase owns credentials and native session persistence. No tokens/passwords
/// are copied into application storage or profile documents.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database = database ?? FirebaseFirestore.instance;
  final FirebaseAuth _auth;
  final FirebaseFirestore _database;
  Future<void>? _googleReady;
  AuthIdentity? _identity(User? user) => user == null
      ? null
      : AuthIdentity(
          uid: user.uid,
          email: user.email,
          verified: user.emailVerified,
        );
  @override
  Stream<AuthIdentity?> get changes => _auth.idTokenChanges().map(_identity);
  @override
  AuthIdentity? get current => _identity(_auth.currentUser);

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, messageFor(e.code));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('cancelled', '');
      }
      throw const AuthFailure(
        'google-failed',
        'No pudimos continuar con Google. Vuelve a intentarlo.',
      );
    } on FirebaseException catch (_) {
      throw const AuthFailure(
        'profile-unavailable',
        'No pudimos consultar tu perfil. Comprueba la conexión y reintenta.',
      );
    }
  }

  @override
  Future<void> login(String email, String password) => _run(() async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  });
  @override
  Future<void> register(String email, String password) => _run(() async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  });
  @override
  Future<void> google() => _run(() async {
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      _googleReady ??= GoogleSignIn.instance.initialize();
      try {
        await _googleReady;
      } catch (_) {
        _googleReady = null;
        rethrow;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) {
        throw const AuthFailure(
          'google-failed',
          'Google no pudo confirmar tu identidad. Reintenta.',
        );
      }
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: token),
      );
    }
  });
  @override
  Future<void> resetPassword(String email) => _run(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') rethrow;
    }
  });
  @override
  Future<void> sendVerification() => _run(() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(
        'requires-recent-login',
        'Inicia sesión otra vez para continuar.',
      );
    }
    await user.sendEmailVerification();
  });
  @override
  Future<void> refresh() => _run(() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true);
  });
  @override
  Future<void> ensureProfile() => _run(() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) {
      throw const AuthFailure(
        'unverified',
        'Verifica tu correo para continuar.',
      );
    }
    final reference = _database.collection('users').doc(user.uid);
    final existing = await reference.get();
    if (existing.exists) return;
    // A missing cache entry is not evidence that a profile does not exist.
    await _database.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        transaction.set(reference, {
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email,
          'photoUrl': user.photoURL,
          'authProviders': user.providerData.map((p) => p.providerId).toList(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  });
  @override
  Future<void> signOut() async {
    await _run(() => _auth.signOut());
    if (!kIsWeb && _googleReady != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        /* Firebase session has ended. */
      }
    }
  }

  static String messageFor(String code) => switch (code) {
    'invalid-email' => 'Revisa el formato de tu correo.',
    'wrong-password' || 'invalid-credential' || 'user-not-found' =>
      'No pudimos iniciar sesión. Revisa tus datos o recupera tu contraseña.',
    'email-already-in-use' =>
      'No pudimos crear la cuenta con esos datos. Prueba iniciar sesión o recuperar tu contraseña.',
    'weak-password' || 'password-does-not-meet-requirements' =>
      'La contraseña no cumple los requisitos de seguridad de Firebase. Usa una contraseña más segura.',
    'network-request-failed' =>
      'No hay conexión. Tus datos de sesión se conservan; vuelve a intentarlo.',
    'too-many-requests' =>
      'Hubo demasiados intentos. Espera un momento antes de reintentar.',
    'user-disabled' => 'Esta cuenta está deshabilitada. Contacta con soporte.',
    'account-exists-with-different-credential' || 'credential-already-in-use' =>
      'Usa tu método habitual de acceso. Los proveedores se vinculan desde una sesión autenticada.',
    'requires-recent-login' || 'user-token-expired' || 'invalid-user-token' =>
      'Tu sesión ya no es válida. Inicia sesión otra vez.',
    'operation-not-allowed' =>
      'Este método de acceso no está disponible. Prueba otro método.',
    _ => 'No pudimos completar la acción. Vuelve a intentarlo.',
  };
}
