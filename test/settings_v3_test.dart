import 'dart:async';
import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/settings/settings_account.dart';
import 'package:romanza/features/settings/settings_sheet.dart';

void main() {
  setUpAll(() async {
    for (final font in ['Nunito', 'Fredoka']) {
      await (FontLoader(
        font,
      )..addFont(rootBundle.load('assets/fonts/$font.ttf'))).load();
    }
  });
  for (final size in [const Size(390, 844), const Size(412, 924)]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('settings account states fit $size $palette scale $scale', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.view.padding = FakeViewPadding(
            top: 32,
            bottom: size.width == 390 ? 34 : 24,
          );
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final semantics = tester.ensureSemantics();
          for (final account in [
            const SettingsAccount(
              status: AccountStatus.ready,
              name: 'Mara',
              partnerStatus: PartnerStatus.linked,
              partnerName: 'Luis',
            ),
            const SettingsAccount(
              status: AccountStatus.ready,
              name:
                  'Un nombre real muy largo con varios apellidos que debe poder leerse completo',
              partnerStatus: PartnerStatus.none,
            ),
            const SettingsAccount(
              status: AccountStatus.loading,
              partnerStatus: PartnerStatus.loading,
            ),
            const SettingsAccount(
              status: AccountStatus.error,
              partnerStatus: PartnerStatus.error,
            ),
            const SettingsAccount(
              status: AccountStatus.ready,
              name: 'Mara',
              photoUrl: 'https://example.invalid/absent.jpg',
              partnerStatus: PartnerStatus.error,
            ),
          ]) {
            String? destination;
            await tester.pumpWidget(
              MaterialApp(
                theme: romanzaTheme(palette),
                home: Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () async {
                        destination = await showModalBottomSheet<String>(
                          context: tester.element(find.byType(TextButton)),
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => SettingsSheet(account: account),
                        );
                      },
                      child: const Text('Abrir'),
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('Abrir'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(ListTile), findsNWidgets(5));
            expect(find.text('Preferencias'), findsNothing);
            expect(find.text('Administración de pareja'), findsNothing);
            final block = find.byKey(const ValueKey('settings-account'));
            expect(
              tester
                  .getSemantics(block)
                  .getSemanticsData()
                  .hasAction(SemanticsAction.tap),
              isTrue,
            );
            expect(tester.getSize(block).width, size.width - 32);
            if (scale == 1 &&
                account.name == 'Mara' &&
                account.partnerStatus == PartnerStatus.linked) {
              expect(tester.getSize(block).height, 104);
              expect(
                tester.getSize(find.byType(SettingsSheet)).height,
                518 + (size.width == 390 ? 34 : 24),
              );
            }
            if (account.partnerStatus == PartnerStatus.loading ||
                account.partnerStatus == PartnerStatus.error) {
              expect(find.text('Sin pareja vinculada'), findsNothing);
            }
            await tester.ensureVisible(find.text('Mi Pareja'));
            await tester.tap(find.text('Mi Pareja'));
            await tester.pumpAndSettle();
            expect(destination, 'Administración de pareja');
            expect(tester.takeException(), isNull);
          }
          semantics.dispose();
        });
      }
    }
  }
  testWidgets(
    'settings sign out prevents duplicate submissions and reports failures',
    (tester) async {
      final completion = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: romanzaTheme(RomanzaPalette.defaultPalette),
          home: Scaffold(
            body: SettingsSheet(
              account: const SettingsAccount(
                status: AccountStatus.ready,
                name: 'Mara',
              ),
              onSignOut: () {
                calls++;
                return completion.future;
              },
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.text('Cerrar sesión'));
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();
      expect(calls, 1);
      completion.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No pudimos cerrar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
