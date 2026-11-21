import 'package:flutter/material.dart';
import '../../design_system/header_logo.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';

/// Shared geometry for access, verification and account setup. The content can
/// grow or scroll with the keyboard and accessibility text size.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.child,
    this.footer,
    this.title,
  });
  final Widget child;
  final Widget? footer;
  final String? title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null ? null : AppBar(title: Text(title!)),
    body: SafeArea(
      top: title == null,
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    child,
                    if (footer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: footer!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final brand = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HeaderLogo(),
          const SizedBox(width: 10),
          Flexible(
            child: Text('Romanza', style: RomanzaType.heading(24, 32, 600)),
          ),
        ],
      );
      const pill = AuthPill(label: 'A su ritmo', icon: RomanzaSymbol.heart);
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [brand, pill],
      );
    },
  );
}

class AuthPill extends StatelessWidget {
  const AuthPill({super.key, required this.label, required this.icon});
  final String label;
  final RomanzaSymbol icon;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.note,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RomanzaIcon(icon, size: 14, color: c.secondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: RomanzaType.caption.copyWith(color: c.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthEmblem extends StatelessWidget {
  const AuthEmblem({super.key, required this.icon});
  final RomanzaSymbol icon;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return ExcludeSemantics(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: c.note,
            borderRadius: BorderRadius.circular(24),
          ),
          child: RomanzaIcon(icon, size: 30, color: c.ink),
        ),
      ),
    );
  }
}

/// Brand illustration only: no photos, fictitious people or user data.
class TogetherIllustration extends StatelessWidget {
  const TogetherIllustration({super.key});
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: 202,
        child: Center(
          child: SizedBox(
            width: 302,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 15,
                  top: 24,
                  child: Transform.rotate(
                    angle: -.09,
                    child: Container(
                      width: 128,
                      height: 148,
                      decoration: BoxDecoration(
                        color: c.note,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: c.background,
                              shape: BoxShape.circle,
                            ),
                            child: RomanzaIcon(
                              RomanzaSymbol.userRound,
                              size: 30,
                              color: c.ink,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: c.secondary.withValues(alpha: .25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 12,
                  child: Transform.rotate(
                    angle: .09,
                    child: Container(
                      width: 128,
                      height: 148,
                      decoration: BoxDecoration(
                        color: c.plan,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: c.background,
                              shape: BoxShape.circle,
                            ),
                            child: RomanzaIcon(
                              RomanzaSymbol.userRound,
                              size: 30,
                              color: c.ink,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: c.secondary.withValues(alpha: .25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.background, width: 4),
                  ),
                  child: RomanzaIcon(
                    RomanzaSymbol.heart,
                    size: 28,
                    color: c.accent,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: RomanzaIcon(
                    RomanzaSymbol.romanzaNota,
                    size: 26,
                    color: c.secondary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: RomanzaIcon(
                    RomanzaSymbol.romanzaRecuerdos,
                    size: 28,
                    color: c.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthIntro extends StatelessWidget {
  const AuthIntro({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title, subtitle;
  final RomanzaSymbol icon;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthEmblem(icon: icon),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(title, style: RomanzaType.greeting),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: RomanzaType.body.copyWith(
            fontSize: 16,
            height: 24 / 16,
            color: c.secondary,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

InputDecoration authFieldDecoration(
  BuildContext context,
  String label, {
  Widget? suffix,
  String? hint,
}) {
  final c = RomanzaColors.of(context);
  final shape = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: c.border),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    fillColor: c.note.withValues(alpha: .42),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: shape,
    enabledBorder: shape,
    focusedBorder: shape.copyWith(
      borderSide: BorderSide(color: c.ink, width: 2),
    ),
    errorMaxLines: 3,
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
