import 'package:flutter/material.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';
import '../auth/auth_design.dart';
import '../auth/auth_screens.dart';
import '../auth/session_controller.dart';
import '../auth/session_scope.dart';

/// Edits only the signed-in user's display name. Credentials and membership
/// remain under the existing authentication flow and server permissions.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.session});
  final SessionController? session;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  String? _uid;
  bool _showStatus = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = widget.session ?? SessionScope.maybeOf(context);
    if (_uid != session?.identity?.uid) {
      _uid = session?.identity?.uid;
      _name.text = session?.name ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(SessionController session) async {
    if (session.busy ||
        !_form.currentState!.validate() ||
        session.identity?.uid != _uid) {
      return;
    }
    setState(() => _showStatus = true);
    await session.saveName(_name.text);
    if (!mounted || session.identity?.uid != _uid) return;
    if (session.name == _name.text.trim() && session.error == null) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tu nombre se guardó.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session ?? SessionScope.maybeOf(context);
    if (session == null) {
      return const AuthPageLayout(
        title: 'Tu cuenta',
        child: AuthIntro(
          title: 'Tu espacio personal',
          subtitle: 'Inicia sesión para consultar y editar tu cuenta.',
          icon: RomanzaSymbol.userRound,
        ),
      );
    }
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final c = RomanzaColors.of(context);
        final user = session.identity;
        if (user == null || user.uid != _uid) {
          return const AuthPageLayout(
            title: 'Tu cuenta',
            child: Text('La sesión ya no está disponible.'),
          );
        }
        final changed = _name.text.trim() != (session.name ?? '').trim();
        return AuthPageLayout(
          title: 'Tu cuenta',
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AccountAvatar(photoUrl: user.photoUrl),
                ),
                const SizedBox(height: 20),
                Text('Un poco de ti', style: RomanzaType.greeting),
                const SizedBox(height: 8),
                Text(
                  'Así te verá tu pareja en Romanza.',
                  style: RomanzaType.body.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                    color: c.secondary,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  key: const ValueKey('account-name'),
                  controller: _name,
                  enabled: !session.busy,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.nickname],
                  decoration: authFieldDecoration(context, 'Tu nombre'),
                  onChanged: (_) => setState(() => _showStatus = false),
                  onFieldSubmitted: (_) => _save(session),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Tu nombre no puede estar vacío.'
                      : null,
                ),
                const SizedBox(height: 12),
                AuthPrimaryButton(
                  label: 'Guardar cambios',
                  onPressed: session.busy || !changed
                      ? null
                      : () => _save(session),
                ),
                if (_showStatus || session.busy)
                  AuthOperationStatus(session: session),
                const SizedBox(height: 32),
                Text('Acceso a tu cuenta', style: RomanzaType.section),
                const SizedBox(height: 16),
                AccountAccessCard(
                  email: user.email,
                  verified: user.verified,
                  providers: user.providers,
                  onReset: session.busy || user.email == null
                      ? null
                      : () {
                          setState(() => _showStatus = true);
                          session.resetPassword(user.email!);
                        },
                ),
                const SizedBox(height: 16),
                Text(
                  'Cambiar tu nombre no modifica el correo ni el vínculo con tu pareja.',
                  style: RomanzaType.body.copyWith(color: c.secondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, this.photoUrl});
  final String? photoUrl;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final fallback = ColoredBox(
      color: c.note,
      child: RomanzaIcon(RomanzaSymbol.userRound, size: 34, color: c.ink),
    );
    return Semantics(
      image: true,
      label: 'Foto de tu cuenta',
      child: SizedBox.square(
        dimension: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: photoUrl == null
              ? fallback
              : Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => fallback,
                  frameBuilder: (_, child, frame, synchronous) =>
                      frame != null || synchronous ? child : fallback,
                ),
        ),
      ),
    );
  }
}

class AccountAccessCard extends StatelessWidget {
  const AccountAccessCard({
    super.key,
    this.email,
    required this.verified,
    required this.providers,
    this.onReset,
  });
  final String? email;
  final bool verified;
  final List<String> providers;
  final VoidCallback? onReset;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.note,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RomanzaIcon(RomanzaSymbol.mail, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Correo electrónico'),
                    const SizedBox(height: 4),
                    SelectableText(
                      email ?? 'No disponible',
                      style: RomanzaType.body.copyWith(
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              AuthPill(
                label: verified
                    ? 'Correo verificado'
                    : 'Verificación pendiente',
                icon: verified ? RomanzaSymbol.check : RomanzaSymbol.mail,
              ),
              if (providers.contains('google.com'))
                const AuthPill(label: 'Google', icon: RomanzaSymbol.userRound),
              if (providers.contains('password'))
                const AuthPill(
                  label: 'Correo y contraseña',
                  icon: RomanzaSymbol.mail,
                ),
            ],
          ),
          if (providers.contains('password')) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onReset,
              child: const Text('Restablecer contraseña'),
            ),
          ],
        ],
      ),
    );
  }
}
