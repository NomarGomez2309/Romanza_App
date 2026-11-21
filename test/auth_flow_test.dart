import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/features/auth/auth_repository.dart';
import 'package:romanza/features/auth/auth_gate.dart';
import 'package:romanza/features/auth/session_controller.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'support/fake_auth_repository.dart';

Future<void> settleSession() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'restores the same UID, bootstraps once, and retains session offline',
    () async {
      final repository = FakeAuthRepository();
      final session = SessionController(repository);
      await settleSession();
      expect(session.stage, SessionStage.authenticated);
      expect(repository.profileCalls, 1);
      repository.emit(repository.current);
      await settleSession();
      expect(repository.profileCalls, 1);
      repository.refreshFailure = const AuthFailure(
        'network-request-failed',
        'Sin conexión',
      );
      await session.resume();
      expect(session.stage, SessionStage.authenticated);
      expect(session.identity!.uid, 'test-user');
      session.dispose();
    },
  );
  test(
    'pending email cannot bootstrap a profile; verification resumes the session',
    () async {
      final repository = FakeAuthRepository(
        user: const AuthIdentity(uid: 'pending', verified: false),
      );
      final session = SessionController(repository);
      await settleSession();
      expect(session.stage, SessionStage.verification);
      expect(repository.profileCalls, 0);
      repository.emit(const AuthIdentity(uid: 'pending', verified: true));
      await settleSession();
      expect(session.stage, SessionStage.authenticated);
      session.dispose();
    },
  );
  test(
    'password is not trimmed, duplicate submits are ignored, registration sends once',
    () async {
      final repository = FakeAuthRepository(user: null)
        ..pending = Completer<void>();
      final session = SessionController(repository);
      await settleSession();
      final register = session.register(
        '  a@example.invalid ',
        ' keep spaces ',
      );
      await session.register('a@example.invalid', 'other');
      expect(repository.loginCalls, 1);
      expect(repository.lastPassword, ' keep spaces ');
      repository.pending!.complete();
      await register;
      await settleSession();
      expect(session.stage, SessionStage.verification);
      expect(repository.verificationCalls, 1);
      await session.resendVerification();
      expect(repository.verificationCalls, 1);
      session.dispose();
    },
  );
  test('a profile failure retains authentication and can be retried', () async {
    final repository = FakeAuthRepository()
      ..profileFailure = const AuthFailure(
        'network-request-failed',
        'Sin conexión',
      );
    final session = SessionController(repository);
    await settleSession();
    expect(session.stage, SessionStage.error);
    expect(repository.current, isNotNull);
    repository.profileFailure = null;
    await session.retry();
    expect(session.stage, SessionStage.authenticated);
    session.dispose();
  });
  test('disabled and deleted accounts leave authenticated screens', () async {
    for (final code in [
      'user-disabled',
      'user-not-found',
      'user-token-expired',
    ]) {
      final repository = FakeAuthRepository();
      final session = SessionController(repository);
      await settleSession();
      repository.refreshFailure = AuthFailure(code, 'Acceso no disponible');
      await session.resume();
      expect(session.identity, isNull);
      expect(
        session.stage,
        code == 'user-disabled' ? SessionStage.disabled : SessionStage.welcome,
      );
      session.dispose();
    }
  });
  test(
    'reset and login messages do not disclose whether an email exists',
    () async {
      expect(
        FirebaseAuthRepository.messageFor('user-not-found'),
        FirebaseAuthRepository.messageFor('wrong-password'),
      );
      final repository = FakeAuthRepository(user: null);
      final session = SessionController(repository);
      await settleSession();
      await session.resetPassword('unknown@example.invalid');
      expect(session.notice, startsWith('Si el correo corresponde'));
      repository.failure = const AuthFailure('cancelled', '');
      await session.google();
      expect(session.error, isNull);
      expect(session.stage, SessionStage.welcome);
      session.dispose();
    },
  );
  testWidgets(
    'sign-out removes every private route, including an already pushed page',
    (tester) async {
      final repository = FakeAuthRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: romanzaTheme(RomanzaPalette.defaultPalette),
          home: AuthGate(
            repository: repository,
            authenticated: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: TextButton(
                        onPressed: repository.signOut,
                        child: const Text('Salir de privado'),
                      ),
                    ),
                  ),
                ),
                child: const Text('Abrir privado'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir privado'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salir de privado'));
      await tester.pumpAndSettle();
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Salir de privado'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final size in [const Size(390, 844), const Size(412, 924)]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'auth forms fit $size scale $scale, validate confirmation and show recovery',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(top: 32, bottom: 24);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final repository = FakeAuthRepository(user: null);
          await tester.pumpWidget(
            MaterialApp(
              theme: romanzaTheme(RomanzaPalette.forest),
              home: AuthGate(
                repository: repository,
                authenticated: (_) => const Text('Privado'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Continuar con correo'));
          await tester.tap(find.text('Continuar con correo'));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('auth-email')),
            'bad',
          );
          await tester.enterText(
            find.byKey(const ValueKey('auth-password')),
            'password',
          );
          await tester.enterText(
            find.byKey(const ValueKey('auth-confirmation')),
            'different',
          );
          await tester.ensureVisible(
            find.widgetWithText(FilledButton, 'Crear cuenta'),
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
          await tester.pumpAndSettle();
          expect(repository.loginCalls, 0);
          expect(find.text('Escribe un correo válido.'), findsOneWidget);
          expect(find.text('Las contraseñas deben coincidir.'), findsOneWidget);
          await tester.ensureVisible(find.text('Ya tengo una cuenta'));
          await tester.tap(find.text('Ya tengo una cuenta'));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Olvidé mi contraseña'));
          await tester.tap(find.text('Olvidé mi contraseña'));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('auth-email')),
            'hello@example.invalid',
          );
          await tester.ensureVisible(find.text('Enviar instrucciones'));
          await tester.tap(find.text('Enviar instrucciones'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Si el correo corresponde'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
