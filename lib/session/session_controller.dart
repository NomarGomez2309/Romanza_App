import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';

enum SessionStage {
  loading,
  welcome,
  verification,
  profile,
  legalUnavailable,
  terms,
  pairing,
  dashboard,
  error,
}

SessionStage resolveSession(
  SessionIdentity? user,
  UserProfile? profile,
  LegalDocuments? legal,
) {
  if (user == null) return SessionStage.welcome;
  if (!user.verified) return SessionStage.verification;
  if (profile == null) return SessionStage.loading;
  if (profile.displayName.trim().isEmpty) return SessionStage.profile;
  if (legal == null || !legal.valid) return SessionStage.legalUnavailable;
  if (profile.acceptedTermsVersion != legal.version) return SessionStage.terms;
  if (profile.coupleId == null && !profile.skipped) return SessionStage.pairing;
  return SessionStage.dashboard;
}

class SessionController extends ChangeNotifier {
  SessionController(this.auth, this.data) {
    _authSub = auth.changes.listen(_onUser, onError: _onError);
  }
  final AuthGateway auth;
  final SessionData data;
  StreamSubscription<SessionIdentity?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<LegalDocuments?>? _legalSub;
  Timer? _timer;
  int _generation = 0;
  bool _disposed = false;
  bool _hasProfile = false;
  bool _hasLegal = false;
  SessionStage stage = SessionStage.loading;
  SessionIdentity? user;
  UserProfile? profile;
  LegalDocuments? legal;
  String? error;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _onError(Object e) {
    if (_disposed) return;
    _timer?.cancel();
    error = e is StateError
        ? e.message.toString()
        : 'No pudimos cargar tu sesión. Revisa tu conexión y reintenta.';
    stage = SessionStage.error;
    _emit(); // Never sign out due to an offline/read failure.
  }

  Future<void> _onUser(SessionIdentity? identity) async {
    final generation = ++_generation;
    _timer?.cancel();
    final previousProfile = _profileSub;
    final previousLegal = _legalSub;
    _profileSub = null;
    _legalSub = null;
    await previousProfile?.cancel();
    await previousLegal?.cancel();
    if (_disposed || generation != _generation) return;
    user = identity;
    profile = null;
    legal = null;
    error = null;
    _hasProfile = false;
    _hasLegal = false;
    stage = identity == null
        ? SessionStage.welcome
        : !identity.verified
        ? SessionStage.verification
        : SessionStage.loading;
    _emit();
    if (identity == null || !identity.verified) return;
    _timer = Timer(const Duration(seconds: 15), () {
      if (generation == _generation && (!_hasProfile || !_hasLegal)) {
        _onError(
          StateError(
            'La carga está tardando. Puedes reintentar sin cerrar sesión.',
          ),
        );
      }
    });
    try {
      await data.ensureProfile(identity.uid);
      if (_disposed || generation != _generation) return;
      _profileSub = data
          .watchProfile(identity.uid)
          .listen(
            (value) {
              if (generation != _generation) return;
              profile = value;
              _hasProfile = true;
              _resolve();
            },
            onError: (Object e) {
              if (generation == _generation) _onError(e);
            },
          );
      _legalSub = data.watchLegal().listen(
        (value) {
          if (generation != _generation) return;
          legal = value;
          _hasLegal = true;
          _resolve();
        },
        onError: (Object e) {
          if (generation == _generation) _onError(e);
        },
      );
    } catch (e) {
      if (generation == _generation) _onError(e);
    }
  }

  void _resolve() {
    if (!_hasProfile || !_hasLegal) return;
    _timer?.cancel();
    if (profile == null) {
      _onError(StateError('No encontramos tu perfil. Reintenta.'));
      return;
    }
    error = null;
    stage = resolveSession(user, profile, legal);
    _emit();
  }

  Future<void> retry() => _onUser(auth.current);
  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    unawaited(_authSub?.cancel());
    unawaited(_profileSub?.cancel());
    unawaited(_legalSub?.cancel());
    super.dispose();
  }
}
