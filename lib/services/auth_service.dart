import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SessionIdentity {
  const SessionIdentity({
    required this.uid,
    required this.verified,
    this.email,
  });
  final String uid;
  final bool verified;
  final String? email;
}

abstract interface class AuthGateway {
  Stream<SessionIdentity?> get changes;
  SessionIdentity? get current;
  Future<void> signOut();
}

class AuthService implements AuthGateway {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  Future<void>? _googleReady;
  DateTime? _lastVerification;
  String? _verificationUid;

  SessionIdentity? _identity(User? user) => user == null
      ? null
      : SessionIdentity(
          uid: user.uid,
          email: user.email,
          verified: user.emailVerified,
        );
  @override
  Stream<SessionIdentity?> get changes => _auth.userChanges().map(_identity);
  @override
  SessionIdentity? get current => _identity(_auth.currentUser);

  Future<void> register(String email, String password) async {
    // Passwords are opaque: never trim or otherwise transform them.
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> _initializeGoogle() => _googleReady ??= GoogleSignIn.instance
      .initialize()
      .catchError((Object error) {
        _googleReady = null;
        throw error;
      });
  Future<OAuthCredential> _googleCredential() async {
    await _initializeGoogle();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw StateError('Google no devolvió una credencial.');
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  Future<void> googleLogin() async {
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      await _auth.signInWithCredential(await _googleCredential());
    }
  }

  Future<void> linkGoogle() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Inicia sesión primero.');
    if (kIsWeb) {
      await user.linkWithPopup(GoogleAuthProvider());
    } else {
      await user.linkWithCredential(await _googleCredential());
    }
  }

  Future<void> sendVerification() async {
    final user = _auth.currentUser;
    if (user == null || user.emailVerified) return;
    final now = DateTime.now();
    if (_verificationUid == user.uid &&
        _lastVerification != null &&
        now.difference(_lastVerification!).inSeconds < 60) {
      throw StateError('Espera un minuto antes de volver a enviar el correo.');
    }
    await user.sendEmailVerification();
    _verificationUid = user.uid;
    _lastVerification = now;
  }

  Future<void> refreshVerification() async {
    await _auth.currentUser?.reload();
    // Refresh the backend claim used by Rules and callables.
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      if (error.code != 'user-not-found') rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut(); // Always end the app session, even if Google fails.
    if (!kIsWeb && _googleReady != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        /* Session ended. */
      }
    }
  }
}

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' => 'Revisa tu conexión e inténtalo de nuevo.',
      'too-many-requests' =>
        'Demasiados intentos. Espera antes de volver a probar.',
      'weak-password' || 'password-does-not-meet-requirements' =>
        'La contraseña no cumple la política de seguridad.',
      'account-exists-with-different-credential' ||
      'credential-already-in-use' =>
        'Usa tu método de acceso original. Puedes vincular Google desde tu cuenta.',
      'provider-already-linked' => 'Google ya está vinculado a esta cuenta.',
      'requires-recent-login' =>
        'Vuelve a iniciar sesión para realizar este cambio.',
      _ =>
        'No pudimos completar el acceso. Revisa tus datos o recupera tu contraseña.',
    };
  }
  if (error is GoogleSignInException &&
      error.code == GoogleSignInExceptionCode.canceled) {
    return 'Acceso con Google cancelado.';
  }
  if (error is StateError) return error.message.toString();
  return 'No pudimos completar la operación. Inténtalo de nuevo.';
}
