import 'dart:async' show Completer;
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/auth/auth_gate.dart';
import 'package:romanza/features/auth/auth_repository.dart';
import 'package:romanza/features/auth/auth_screens.dart';
import 'package:romanza/features/auth/profile_setup_screen.dart';
import 'package:romanza/features/auth/session_controller.dart';
import 'package:romanza/features/settings/account_screen.dart';
import 'package:romanza/features/settings/settings_sheet.dart';
import 'package:romanza/features/settings/settings_account.dart';
import 'support/fake_auth_repository.dart';

void main() {
  setUpAll(() async {
    for (final font in ['Nunito', 'Fredoka']) {
      await (FontLoader(
        font,
      )..addFont(rootBundle.load('assets/fonts/$font.ttf'))).load();
    }
  });
  testWidgets('welcome keeps Google, registration and login destinations', (
    tester,
  ) async {
    final repository = FakeAuthRepository(user: null);
    final session = SessionController(repository);
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        theme: romanzaTheme(RomanzaPalette.defaultPalette),
        home: AuthWelcomeScreen(session: session),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Romanza es para mayores de 18 años.'), findsNothing);
    expect(find.text('A su ritmo'), findsNothing);
    await tester.tap(find.text('Continuar con correo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('auth-confirmation')), findsOneWidget);
    await tester.ensureVisible(find.text('Privacidad · Borrador'));
    await tester.tap(find.text('Privacidad · Borrador'));
    await tester.pumpAndSettle();
    expect(find.text('Privacidad · Borrador'), findsOneWidget);
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(EmailAccessScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Qué bueno verte'), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-confirmation')), findsNothing);
    Navigator.of(tester.element(find.byType(EmailAccessScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();
    expect(session.identity?.uid, 'google-user');
    await tester.pumpWidget(const SizedBox());
    session.dispose();
  });

  test(
    'verified users without a name finish setup once and preserve it on return',
    () async {
      final repository = FakeAuthRepository()..name = '';
      final session = SessionController(repository);
      await Future<void>.delayed(Duration.zero);
      expect(session.stage, SessionStage.profile);
      repository.profileFailure = const AuthFailure(
        'offline',
        'No pudimos guardar.',
      );
      await session.saveName('Mara');
      expect(session.stage, SessionStage.profile);
      expect(session.name, '');
      expect(session.error, isNotNull);
      repository.profileFailure = null;
      await session.saveName('  Mara  ');
      expect(session.stage, SessionStage.authenticated);
      expect(session.name, 'Mara');
      repository.emit(repository.current);
      await Future<void>.delayed(Duration.zero);
      expect(session.stage, SessionStage.authenticated);
      session.dispose();
    },
  );
  test(
    'a late name save cannot replace the profile of another signed-in account',
    () async {
      final repository = FakeAuthRepository();
      final session = SessionController(repository);
      await Future<void>.delayed(Duration.zero);
      repository.namePending = Completer<void>();
      final saving = session.saveName('Luz');
      repository.emit(const AuthIdentity(uid: 'other-user', verified: true));
      await Future<void>.delayed(Duration.zero);
      repository.namePending!.complete();
      await saving;
      expect(session.identity!.uid, 'other-user');
      expect(session.name, 'Mara');
      session.dispose();
    },
  );
  testWidgets('sign-out removes the account editor and its personal fields', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: romanzaTheme(RomanzaPalette.forest),
        home: AuthGate(
          repository: repository,
          authenticated: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AccountScreen()),
              ),
              child: const Text('Abrir cuenta'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir cuenta'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);
    await repository.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsNothing);
    expect(find.text('test@example.invalid'), findsNothing);
    expect(find.text('Continuar con Google'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'blank names cannot bypass setup and saving enters the real authenticated route',
    (tester) async {
      final repository = FakeAuthRepository()..name = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: romanzaTheme(RomanzaPalette.forest),
          home: AuthGate(
            repository: repository,
            authenticated: (_) =>
                const Scaffold(body: Text('Inicio autenticado')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfileSetupScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Entrar a Romanza'));
      await tester.tap(find.text('Entrar a Romanza'));
      await tester.pumpAndSettle();
      expect(repository.nameSaves, 0);
      expect(find.text('Escribe tu nombre para continuar.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('profile-name')),
        'Mara',
      );
      await tester.ensureVisible(find.text('Entrar a Romanza'));
      await tester.tap(find.text('Entrar a Romanza'));
      await tester.pumpAndSettle();
      expect(find.text('Inicio autenticado'), findsOneWidget);
      expect(repository.name, 'Mara');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'account edits persist the name and a failure preserves the draft',
    (tester) async {
      final repository = FakeAuthRepository();
      final session = SessionController(repository);
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          theme: romanzaTheme(RomanzaPalette.forest),
          home: AccountScreen(session: session),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Guardar cambios'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('account-name')),
        '  Luz  ',
      );
      repository.profileFailure = const AuthFailure(
        'offline',
        'No pudimos guardar el nombre.',
      );
      await tester.ensureVisible(find.text('Guardar cambios'));
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      expect(session.name, 'Mara');
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('account-name')))
            .controller!
            .text,
        '  Luz  ',
      );
      repository.profileFailure = null;
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      expect(session.name, 'Luz');
      expect(repository.name, 'Luz');
      await tester.pumpWidget(const SizedBox());
      session.dispose();
    },
  );

  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    final welcome =
        const bool.fromEnvironment('CAPTURE_WELCOME') &&
        name.startsWith('welcome-');
    if (!welcome && !const bool.fromEnvironment('CAPTURE_DESIGN')) return;
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final folder = welcome ? 'welcome-waves' : 'onboarding-v1';
      final file = File('docs/qa/evidence/$folder/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final size in [const Size(390, 844), const Size(412, 924)]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('onboarding and account fit $size $palette text $scale', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.view.padding =
              const FakeViewPadding(); // Insets supplied below via MediaQuery.
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final repository = FakeAuthRepository(user: null);
          final session = SessionController(repository);
          await tester.pump();
          final key = GlobalKey();
          var keyboardInset = 0.0;
          Future<void> show(Widget child) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: romanzaTheme(palette),
                home: RepaintBoundary(
                  key: key,
                  child: MediaQuery(
                    data: MediaQueryData(
                      size: size,
                      padding: EdgeInsets.only(
                        top: 32,
                        bottom: size.width == 390 ? 34 : 24,
                      ),
                      viewInsets: EdgeInsets.only(bottom: keyboardInset),
                      textScaler: TextScaler.linear(scale),
                    ),
                    child: child,
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await show(AuthWelcomeScreen(session: session));
          if (scale == 1) {
            await capture(
              tester,
              key,
              'welcome-${palette.label.toLowerCase()}-${size.width.toInt()}',
            );
          }
          await show(
            EmailAccessScreen(session: session, mode: EmailAccessMode.register),
          );
          if (size.width == 412 &&
              scale == 1 &&
              palette == RomanzaPalette.defaultPalette) {
            await capture(tester, key, 'register-default-412');
          }
          repository.name = '';
          repository.emit(
            const AuthIdentity(
              uid: 'a',
              email: 'mara@example.invalid',
              verified: true,
              providers: ['password'],
            ),
          );
          await tester.pumpAndSettle();
          await show(ProfileSetupScreen(session: session));
          if (size.width == 390 &&
              scale == 1 &&
              palette == RomanzaPalette.forest) {
            await capture(tester, key, 'profile-forest-390');
          }
          await session.saveName('Mara');
          await show(AccountScreen(session: session));
          if (size.width == 390 &&
              scale == 1 &&
              palette == RomanzaPalette.forest) {
            await capture(tester, key, 'account-forest-390');
          }
          if (size.width == 412 &&
              palette == RomanzaPalette.forest &&
              scale == 2) {
            keyboardInset = 320;
            await show(AccountScreen(session: session));
            await tester.ensureVisible(find.text('Guardar cambios'));
            expect(tester.takeException(), isNull);
            keyboardInset = 0;
          }
          await show(
            const Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: SettingsSheet(
                  account: SettingsAccount(
                    status: AccountStatus.ready,
                    name: 'Mara',
                    partnerStatus: PartnerStatus.none,
                  ),
                ),
              ),
            ),
          );
          if (size.width == 390 &&
              scale == 1 &&
              palette == RomanzaPalette.forest) {
            await capture(tester, key, 'settings-forest-390');
          }
          await tester.pumpWidget(const SizedBox());
          session.dispose();
        });
      }
    }
  }
}
