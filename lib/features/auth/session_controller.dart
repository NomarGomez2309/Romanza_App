import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_repository.dart';

enum SessionStage {
  loading,
  welcome,
  verification,
  profile,
  authenticated,
  error,
  disabled,
}

class SessionController extends ChangeNotifier {
  SessionController(this.repository) {
    _subscription = repository.changes.listen(_received, onError: _failed);
    _startup = Timer(const Duration(seconds: 15), () {
      if (stage == SessionStage.loading && !_disposed) {
        stage = SessionStage.error;
        error = 'No pudimos recuperar la sesión. Puedes reintentar.';
        notifyListeners();
      }
    });
  }
  final AuthRepository repository;
  StreamSubscription<AuthIdentity?>? _subscription;
  Timer? _startup, _cooldownTimer;
  SessionStage stage = SessionStage.loading;
  AuthIdentity? identity;
  String? error, notice;
  String? name;
  bool busy = false, _disposed = false;
  String? _profileUid;
  int _generation = 0;
  int verificationCooldown = 0;
  bool _disabled = false;
  bool _invalidating = false;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _received(AuthIdentity? user) async {
    if (_disposed || _invalidating) return;
    _startup?.cancel();
    final generation = ++_generation;
    final previousUid = identity?.uid;
    identity = user;
    if (previousUid != user?.uid) {
      _profileUid = null;
      name = null;
      error = null;
      notice = null;
      _cooldownTimer?.cancel();
      verificationCooldown = 0;
    }
    if (user == null) {
      stage = _disabled ? SessionStage.disabled : SessionStage.welcome;
    } else if (!user.verified) {
      stage = SessionStage.verification;
    } else if (_profileUid == user.uid) {
      stage = name == null || name!.trim().isEmpty
          ? SessionStage.profile
          : SessionStage.authenticated;
    } else {
      stage = SessionStage.loading;
      _emit();
      try {
        await repository.ensureProfile().timeout(const Duration(seconds: 20));
        if (_disposed || generation != _generation) return;
        final profileName = await repository.readName().timeout(
          const Duration(seconds: 20),
        );
        if (_disposed || generation != _generation) return;
        _profileUid = user.uid;
        name = profileName;
        error = null;
        stage = profileName.trim().isEmpty
            ? SessionStage.profile
            : SessionStage.authenticated;
      } catch (e) {
        if (_disposed || generation != _generation) return;
        error = _message(e);
        stage = SessionStage.error;
      }
    }
    _emit();
  }

  String _message(Object e) => e is AuthFailure
      ? e.message
      : 'No pudimos completar la acción. Comprueba la conexión y reintenta.';
  void _failed(Object e) {
    _startup?.cancel();
    error = _message(e);
    stage = SessionStage.error;
    _emit();
  }

  Future<void> _action(Future<void> Function() operation) async {
    if (busy || _disposed) return;
    busy = true;
    error = null;
    notice = null;
    _disabled = false;
    _emit();
    try {
      await operation();
    } catch (e) {
      if (e is! AuthFailure || e.code != 'cancelled') error = _message(e);
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<void> saveName(String value) => _action(() async {
    final uid = identity?.uid;
    final generation = _generation;
    if (uid == null || identity?.verified != true) return;
    await repository.saveName(value);
    if (_disposed || generation != _generation || identity?.uid != uid) return;
    name = value.trim();
    stage = SessionStage.authenticated;
    notice = 'Tu nombre se guardó.';
  });

  Future<void> login(String email, String password) =>
      _action(() => repository.login(email, password));
  Future<void> google() => _action(repository.google);
  Future<void> register(String email, String password) => _action(() async {
    await repository.register(email, password);
    await _received(repository.current);
    try {
      await _sendVerification();
    } catch (_) {
      error =
          'La cuenta se creó, pero no pudimos enviar el correo de verificación. Puedes reenviarlo.';
    }
  });
  Future<void> resetPassword(String email) => _action(() async {
    await repository.resetPassword(email);
    notice =
        'Si el correo corresponde a una cuenta, recibirás instrucciones para recuperar el acceso.';
  });
  Future<void> resendVerification() async {
    if (verificationCooldown > 0) return;
    await _action(_sendVerification);
  }

  Future<void> _sendVerification() async {
    await repository.sendVerification();
    verificationCooldown = 60;
    notice = 'Revisa tu correo y la carpeta de spam.';
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      verificationCooldown--;
      if (verificationCooldown <= 0) timer.cancel();
      _emit();
    });
  }

  Future<void> checkVerification() => _action(() async {
    await repository.refresh();
    await _received(repository.current);
    if (stage == SessionStage.verification) {
      notice = 'El correo todavía figura como pendiente de verificar.';
    }
  });
  Future<void> retry() async {
    if (busy) return;
    await _action(() async {
      await repository.refresh();
      await _received(repository.current);
    });
  }

  Future<void> resume() async {
    if (busy || identity == null || _disposed || _invalidating) return;
    try {
      await repository.refresh().timeout(const Duration(seconds: 20));
    } on AuthFailure catch (e) {
      if ([
        'user-disabled',
        'user-not-found',
        'user-token-expired',
        'invalid-user-token',
      ].contains(e.code)) {
        _invalidating = true;
        ++_generation;
        try {
          await repository.signOut();
        } catch (_) {
          // A rejected session must not regain access because local cleanup failed.
        } finally {
          _invalidating = false;
          identity = null;
          _profileUid = null;
          name = null;
          _disabled = e.code == 'user-disabled';
          stage = _disabled ? SessionStage.disabled : SessionStage.welcome;
          error = e.code == 'user-not-found'
              ? 'La cuenta ya no está disponible.'
              : e.message;
          _emit();
        }
      }
      // A network failure alone never destroys a known native session.
    } catch (_) {
      /* Retry on the next resume or explicit user action. */
    }
  }

  Future<void> signOut() => _action(repository.signOut);
  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _subscription?.cancel();
    _startup?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
