import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/services/auth_service.dart';
import 'package:romanza/services/profile_repository.dart';
import 'package:romanza/session/session_controller.dart';

const legal = LegalDocuments(
  version: 'v1',
  termsUrl: 'https://example.com/terms',
  privacyUrl: 'https://example.com/privacy',
);
const verified = SessionIdentity(uid: 'a', verified: true);
UserProfile profile({
  String uid = 'a',
  String name = 'Alex',
  String? terms = 'v1',
  bool skipped = false,
  String? coupleId,
}) => UserProfile(
  uid: uid,
  displayName: name,
  acceptedTermsVersion: terms,
  skipped: skipped,
  coupleId: coupleId,
);

class FakeAuth implements AuthGateway {
  final events = StreamController<SessionIdentity?>.broadcast();
  @override
  SessionIdentity? current;
  int signOuts = 0;
  @override
  Stream<SessionIdentity?> get changes => events.stream;
  void emit(SessionIdentity? user) {
    current = user;
    events.add(user);
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    emit(null);
  }
}

class FakeData implements SessionData {
  final profiles = <String, StreamController<UserProfile?>>{};
  final legalEvents = StreamController<LegalDocuments?>.broadcast();
  final pending = <String, Completer<void>>{};
  final ensured = <String>[];
  @override
  Future<void> ensureProfile(String uid) async {
    ensured.add(uid);
    await pending[uid]?.future;
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      (profiles[uid] ??= StreamController<UserProfile?>.broadcast()).stream;
  @override
  Stream<LegalDocuments?> watchLegal() => legalEvents.stream;
  void emit(String uid, UserProfile? value) {
    profiles[uid]!.add(value);
    legalEvents.add(legal);
  }

  Future<void> close() async {
    await legalEvents.close();
    for (final stream in profiles.values) {
      await stream.close();
    }
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);
void main() {
  test(
    'routes through verification, profile and published policy before pairing',
    () {
      expect(resolveSession(null, null, null), SessionStage.welcome);
      expect(
        resolveSession(
          const SessionIdentity(uid: 'a', verified: false),
          null,
          null,
        ),
        SessionStage.verification,
      );
      expect(resolveSession(verified, null, legal), SessionStage.loading);
      expect(
        resolveSession(verified, profile(name: ''), legal),
        SessionStage.profile,
      );
      expect(
        resolveSession(verified, profile(), null),
        SessionStage.legalUnavailable,
      );
      expect(
        resolveSession(verified, profile(terms: null), legal),
        SessionStage.terms,
      );
      expect(
        resolveSession(verified, profile(terms: 'old'), legal),
        SessionStage.terms,
      );
      expect(resolveSession(verified, profile(), legal), SessionStage.pairing);
    },
  );
  test(
    'skip is persistent and both linked and unlinked users can reach the hub',
    () {
      expect(
        resolveSession(verified, profile(skipped: true), legal),
        SessionStage.dashboard,
      );
      expect(
        resolveSession(verified, profile(coupleId: 'couple'), legal),
        SessionStage.dashboard,
      );
      expect(
        resolveSession(verified, profile(skipped: true, terms: 'old'), legal),
        SessionStage.terms,
      );
    },
  );
  test('invalid legal URLs never produce an acceptance screen', () {
    const invalid = LegalDocuments(
      version: 'v1',
      termsUrl: 'http://example.com',
      privacyUrl: 'https://example.com',
    );
    expect(
      resolveSession(verified, profile(), invalid),
      SessionStage.legalUnavailable,
    );
  });
  test('auth failures do not reveal whether an email exists', () {
    final messages =
        [
              'user-not-found',
              'wrong-password',
              'email-already-in-use',
              'invalid-credential',
            ]
            .map((code) => authErrorMessage(FirebaseAuthException(code: code)))
            .toSet();
    expect(messages.length, 1);
  });
  test('unverified users never bootstrap or read a profile', () async {
    final auth = FakeAuth();
    final data = FakeData();
    final controller = SessionController(auth, data);
    auth.emit(const SessionIdentity(uid: 'a', verified: false));
    await flush();
    expect(controller.stage, SessionStage.verification);
    expect(data.ensured, isEmpty);
    controller.dispose();
    await auth.events.close();
    await data.close();
  });
  test(
    'offline profile errors preserve identity; retry can recover without sign-out',
    () async {
      final auth = FakeAuth();
      final data = FakeData();
      final controller = SessionController(auth, data);
      auth.emit(verified);
      await flush();
      data.emit('a', profile(skipped: true));
      await flush();
      expect(controller.stage, SessionStage.dashboard);
      data.profiles['a']!.addError(StateError('offline'));
      await flush();
      expect(controller.stage, SessionStage.error);
      expect(controller.user?.uid, 'a');
      expect(auth.signOuts, 0);
      await controller.retry();
      data.emit('a', profile(skipped: true));
      await flush();
      expect(controller.stage, SessionStage.dashboard);
      controller.dispose();
      await auth.events.close();
      await data.close();
    },
  );
  test(
    'a slow bootstrap from a previous user cannot overwrite a newer session',
    () async {
      final auth = FakeAuth();
      final data = FakeData();
      data.pending['a'] = Completer<void>();
      final controller = SessionController(auth, data);
      auth.emit(verified);
      await flush();
      auth.emit(const SessionIdentity(uid: 'b', verified: true));
      await flush();
      data.emit('b', profile(uid: 'b', skipped: true));
      await flush();
      data.pending['a']!.complete();
      await flush();
      expect(controller.user?.uid, 'b');
      expect(controller.profile?.uid, 'b');
      expect(controller.stage, SessionStage.dashboard);
      auth.emit(null);
      await flush();
      expect(controller.stage, SessionStage.welcome);
      expect(controller.profile, isNull);
      controller.dispose();
      await auth.events.close();
      await data.close();
    },
  );
}
