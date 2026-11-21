import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';
import '../../preferences/palette_controller.dart';
import '../../preferences/preferences_screen.dart';
import 'settings_account.dart';
import 'settings_localizations.dart';
import 'legal_draft_screen.dart';
import 'account_screen.dart';

Future<void> openSettings(
  BuildContext context,
  PaletteController controller, {
  FocusNode? returnFocus,
}) async {
  final previousFocus = returnFocus ?? FocusManager.instance.primaryFocus;
  final destination = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .24),
    showDragHandle: false,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(duration: Duration(milliseconds: 250)),
    builder: (_) => const _LiveSettingsSheet(),
  );
  if (previousFocus?.context != null) previousFocus!.requestFocus();
  if (!context.mounted || destination == null) return;
  if (destination == 'signedOut') {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => destination == 'Cuenta'
          ? const AccountScreen()
          : destination == 'Preferencias'
          ? PreferencesScreen(controller: controller)
          : SettingsDetail(title: destination, controller: controller),
    ),
  );
}

class _LiveSettingsSheet extends StatefulWidget {
  const _LiveSettingsSheet();
  @override
  State<_LiveSettingsSheet> createState() => _LiveSettingsSheetState();
}

class _LiveSettingsSheetState extends State<_LiveSettingsSheet> {
  SettingsAccount account = const SettingsAccount();
  SettingsAccountSubscription? subscription;
  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty) {
      account = const SettingsAccount(
        status: AccountStatus.loading,
        partnerStatus: PartnerStatus.loading,
      );
      subscription = SettingsAccountSubscription((value) {
        if (mounted) setState(() => account = value);
      });
    }
  }

  @override
  void dispose() {
    subscription?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsSheet(
    account: account,
    onSignOut:
        Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null
        ? () => FirebaseAuth.instance.signOut()
        : null,
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    this.account = const SettingsAccount(),
    this.onSignOut,
  });
  final SettingsAccount account;
  final Future<void> Function()? onSignOut;
  // Route keys remain unchanged; labels are localized independently.
  static const entries = <String, RomanzaSymbol>{
    'Preferencias': RomanzaSymbol.slidersHorizontal,
    'Administración de pareja': RomanzaSymbol.link,
    'Idioma': RomanzaSymbol.globe,
    'Términos y condiciones': RomanzaSymbol.fileText,
    'Cerrar sesión': RomanzaSymbol.logOut,
  };
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool signingOut = false;
  String? error;
  Future<void> signOut() async {
    if (signingOut || widget.onSignOut == null) return;
    setState(() {
      signingOut = true;
      error = null;
    });
    try {
      await widget.onSignOut!();
      if (mounted) Navigator.pop(context, 'signedOut');
    } catch (_) {
      if (mounted) {
        setState(() {
          signingOut = false;
          error = 'No pudimos cerrar la sesión. Vuelve a intentarlo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final copy = SettingsLocalizations.of(context);
    final opaque =
        MediaQuery.highContrastOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    final content = SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 3,
                        color: c.secondary,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              copy.title,
                              style: RomanzaType.heading(26, 32, 600),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar configuración',
                          onPressed: signingOut
                              ? null
                              : () => Navigator.pop(context),
                          icon: const RomanzaIcon(RomanzaSymbol.x, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AccountBlock(
                account: widget.account,
                onTap: signingOut
                    ? null
                    : () => Navigator.pop(context, 'Cuenta'),
              ),
            ),
            const SizedBox(height: 17),
            for (final entry in SettingsSheet.entries.entries)
              ListTile(
                minTileHeight: 58,
                minVerticalPadding: 17,
                contentPadding: const EdgeInsets.symmetric(horizontal: 27),
                minLeadingWidth: 24,
                horizontalTitleGap: 19,
                leading: RomanzaIcon(entry.value, size: 24, color: c.ink),
                title: Text(
                  copy.destination(entry.key),
                  style: RomanzaType.body.copyWith(
                    fontSize: 17,
                    height: 24 / 17,
                    color: c.ink,
                  ),
                ),
                enabled:
                    !signingOut &&
                    (entry.key != 'Cerrar sesión' || widget.onSignOut != null),
                onTap: entry.key == 'Cerrar sesión'
                    ? signOut
                    : () => Navigator.pop(context, entry.key),
              ),
            const SizedBox(height: 17),
            if (signingOut)
              const LinearProgressIndicator(semanticsLabel: 'Cerrando sesión'),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(liveRegion: true, child: Text(error!)),
              ),
          ],
        ),
      ),
    );
    return PopScope(
      canPop: !signingOut,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: opaque ? 0 : 20.52,
            sigmaY: opaque ? 0 : 20.52,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: opaque ? c.note : c.note.withValues(alpha: .77),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: .253)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: opaque
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: .06),
                          Colors.transparent,
                        ],
                      ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountBlock extends StatelessWidget {
  const _AccountBlock({required this.account, required this.onTap});
  final SettingsAccount account;
  final VoidCallback? onTap;
  Widget avatar(BuildContext context, double size, String? url) {
    final c = RomanzaColors.of(context);
    final fallback = ColoredBox(
      color: c.background,
      child: RomanzaIcon(
        RomanzaSymbol.userRound,
        size: size * .5,
        color: c.secondary,
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => fallback,
                frameBuilder: (_, child, frame, synchronous) =>
                    frame != null || synchronous ? child : fallback,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final copy = SettingsLocalizations.of(context);
    final name = switch (account.status) {
      AccountStatus.signedOut => copy.signedOut,
      AccountStatus.loading => copy.loading,
      AccountStatus.error => copy.error,
      AccountStatus.ready => account.name ?? copy.unnamed,
    };
    final link = switch (account.partnerStatus) {
      PartnerStatus.none => copy.noPartner,
      PartnerStatus.loading => copy.loadingPartner,
      PartnerStatus.error => copy.partnerError,
      PartnerStatus.linked =>
        account.partnerName == null
            ? copy.partnerError
            : copy.linkedWith(account.partnerName!),
    };
    return Semantics(
      key: const ValueKey('settings-account'),
      button: true,
      onTap: onTap,
      label: '${copy.account}. $name. $link. Abrir Cuenta',
      child: ExcludeSemantics(
        child: Material(
          color: c.background.withValues(alpha: .70),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 104),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 4,
                            child: avatar(context, 46, account.photoUrl),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1.2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.background,
                              ),
                              child: avatar(
                                context,
                                27.6,
                                account.partnerStatus == PartnerStatus.linked
                                    ? account.partnerPhotoUrl
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            copy.account,
                            style: RomanzaType.body.copyWith(
                              fontSize: 13.8,
                              height: 18 / 13.8,
                              color: c.secondary,
                            ),
                          ),
                          Text(
                            name,
                            style: RomanzaType.body.copyWith(
                              fontSize: 19.55,
                              height: 24 / 19.55,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            link,
                            style: RomanzaType.body.copyWith(
                              fontSize: 14.95,
                              height: 20 / 14.95,
                              color: c.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RomanzaIcon(
                      RomanzaSymbol.chevronRight,
                      size: 23,
                      color: c.ink,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsDetail extends StatelessWidget {
  const SettingsDetail({
    super.key,
    required this.title,
    required this.controller,
  });
  final String title;
  final PaletteController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(SettingsLocalizations.of(context).destination(title)),
    ),
    body: SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (title == 'Idioma') ...[
              for (final entry in {
                true: 'Idioma del dispositivo',
                false: 'Español',
              }.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: controller.systemLanguage == entry.key
                      ? const RomanzaIcon(RomanzaSymbol.check)
                      : null,
                  selected: controller.systemLanguage == entry.key,
                  onTap: controller.saving
                      ? null
                      : () => controller.setLanguage(entry.key),
                ),
              const Text(
                'Romanza está disponible en español. Si el dispositivo usa otro idioma, se mostrará en español.',
              ),
              if (controller.saving) const LinearProgressIndicator(),
              if (controller.error != null) Text(controller.error!),
            ] else if (title == 'Términos y condiciones') ...[
              for (final label in [
                'Condiciones de uso',
                'Política de privacidad',
              ])
                ListTile(
                  title: Text(label),
                  trailing: const RomanzaIcon(
                    RomanzaSymbol.arrowLeft,
                    forward: true,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LegalDraftScreen(
                        privacy: label == 'Política de privacidad',
                      ),
                    ),
                  ),
                ),
              ListTile(
                title: const Text('Licencias de terceros'),
                trailing: const RomanzaIcon(
                  RomanzaSymbol.arrowLeft,
                  forward: true,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Romanza',
                ),
              ),
            ] else
              Text(switch (title) {
                'Cuenta' =>
                  Firebase.apps.isEmpty ||
                          FirebaseAuth.instance.currentUser == null
                      ? 'No hay una sesión iniciada.'
                      : 'Correo: ${FirebaseAuth.instance.currentUser!.email ?? "No disponible"}\nLa edición del perfil estará disponible en una próxima entrega.',
                'Administración de pareja' =>
                  'Las invitaciones mediante enlace estarán disponibles en una próxima entrega.',
                _ =>
                  'No hay una sesión iniciada que cerrar. Tus preferencias y borradores permanecen en este dispositivo.',
              }),
          ],
        ),
      ),
    ),
  );
}
