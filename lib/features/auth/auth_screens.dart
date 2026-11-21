import 'package:flutter/material.dart';
import '../../design_system/components.dart';
import '../../design_system/header_logo.dart';
import '../../design_system/romanza_theme.dart';
import 'session_controller.dart';
import 'auth_design.dart';
import '../../design_system/romanza_icon.dart';
import '../settings/legal_draft_screen.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key, required this.session});
  final SessionController session;
  void _email(BuildContext context, EmailAccessMode mode) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EmailAccessScreen(session: session, mode: mode),
        ),
      );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) => AuthPageLayout(
      footer: Column(
        children: [
          Text(
            'Romanza es para mayores de 18 años.',
            style: RomanzaType.caption.copyWith(
              color: RomanzaColors.of(context).secondary,
            ),
            textAlign: TextAlign.center,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final privacy in [false, true])
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LegalDraftScreen(privacy: privacy),
                    ),
                  ),
                  child: Text(
                    privacy ? 'Privacidad · Borrador' : 'Términos · Borrador',
                  ),
                ),
            ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrand(),
          const SizedBox(height: 20),
          const TogetherIllustration(),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              'Más cotidiano.\nMás Romanza.',
              style: RomanzaType.heading(40, 44, 600),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Un espacio para compartir sus días y guardar lo que importa, incluso a la distancia.',
            style: RomanzaType.body.copyWith(
              fontSize: 16,
              height: 24 / 16,
              color: RomanzaColors.of(context).secondary,
            ),
          ),
          const SizedBox(height: 28),
          AuthPrimaryButton(
            label: 'Continuar con Google',
            onPressed: session.busy ? null : session.google,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: session.busy
                ? null
                : () => _email(context, EmailAccessMode.register),
            child: const Text('Continuar con correo'),
          ),
          TextButton(
            onPressed: session.busy
                ? null
                : () => _email(context, EmailAccessMode.login),
            child: const Text('Iniciar sesión'),
          ),
          AuthOperationStatus(session: session),
        ],
      ),
    ),
  );
}

enum EmailAccessMode { login, register, reset }

class EmailAccessScreen extends StatefulWidget {
  const EmailAccessScreen({
    super.key,
    required this.session,
    required this.mode,
  });
  final SessionController session;
  final EmailAccessMode mode;
  @override
  State<EmailAccessScreen> createState() => _EmailAccessScreenState();
}

class _EmailAccessScreenState extends State<EmailAccessScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      confirmation = TextEditingController();
  bool obscure = true;
  late EmailAccessMode mode = widget.mode;
  String get title => switch (mode) {
    EmailAccessMode.login => 'Iniciar sesión',
    EmailAccessMode.register => 'Crear cuenta',
    EmailAccessMode.reset => 'Recuperar acceso',
  };
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (widget.session.busy || !form.currentState!.validate()) return;
    switch (mode) {
      case EmailAccessMode.login:
        await widget.session.login(email.text, password.text);
      case EmailAccessMode.register:
        await widget.session.register(email.text, password.text);
      case EmailAccessMode.reset:
        await widget.session.resetPassword(email.text);
    }
  }

  void selectMode(EmailAccessMode next) {
    if (widget.session.busy) return;
    password.clear();
    confirmation.clear();
    setState(() => mode = next);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.session,
    builder: (context, _) {
      final busy = widget.session.busy;
      return AuthPageLayout(
        title: title,
        child: Form(
          key: form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthIntro(
                  title: mode == EmailAccessMode.login
                      ? 'Qué bueno verte'
                      : mode == EmailAccessMode.register
                      ? 'Su historia empieza aquí'
                      : 'Volvamos a encontrarnos',
                  subtitle: mode == EmailAccessMode.reset
                      ? 'Te enviaremos un enlace para recuperar el acceso.'
                      : mode == EmailAccessMode.register
                      ? 'Crea tu espacio. Lo demás puede ir a su ritmo.'
                      : 'Entra a ese pequeño espacio que comparten.',
                  icon: mode == EmailAccessMode.reset
                      ? RomanzaSymbol.mail
                      : RomanzaSymbol.userRound,
                ),
                TextFormField(
                  key: const ValueKey('auth-email'),
                  controller: email,
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: authFieldDecoration(
                    context,
                    'Correo electrónico',
                    hint: 'tu@correo.com',
                  ),
                  validator: (value) =>
                      RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch((value ?? '').trim())
                      ? null
                      : 'Escribe un correo válido.',
                ),
                if (mode != EmailAccessMode.reset) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('auth-password'),
                    controller: password,
                    enabled: !busy,
                    obscureText: obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: [
                      mode == EmailAccessMode.register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: authFieldDecoration(
                      context,
                      'Contraseña',
                      suffix: TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(() => obscure = !obscure),
                        child: Text(obscure ? 'Mostrar' : 'Ocultar'),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Escribe tu contraseña.'
                        : null,
                  ),
                  if (mode == EmailAccessMode.register) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('auth-confirmation'),
                      controller: confirmation,
                      enabled: !busy,
                      obscureText: obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: authFieldDecoration(
                        context,
                        'Confirmar contraseña',
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => submit(),
                      validator: (value) =>
                          value == password.text && value!.isNotEmpty
                          ? null
                          : 'Las contraseñas deben coincidir.',
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  onPressed: busy ? null : submit,
                  label: mode == EmailAccessMode.reset
                      ? 'Enviar instrucciones'
                      : title,
                ),
                if (mode == EmailAccessMode.login)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => selectMode(EmailAccessMode.reset),
                    child: const Text('Olvidé mi contraseña'),
                  ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () => selectMode(
                          mode == EmailAccessMode.register
                              ? EmailAccessMode.login
                              : EmailAccessMode.register,
                        ),
                  child: Text(
                    mode == EmailAccessMode.register
                        ? 'Ya tengo una cuenta'
                        : 'Crear una cuenta',
                  ),
                ),
                if (mode == EmailAccessMode.reset)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => selectMode(EmailAccessMode.login),
                    child: const Text('Volver a iniciar sesión'),
                  ),
                AuthOperationStatus(session: widget.session),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key, required this.session});
  final SessionController session;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) => AuthPageLayout(
      footer: TextButton(
        onPressed: session.busy ? null : session.signOut,
        child: const Text('Usar otra cuenta'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrand(),
          const SizedBox(height: 56),
          const AuthIntro(
            title: 'Revisa tu correo',
            subtitle:
                'Un pequeño paso para cuidar tu cuenta. Abre el enlace que te enviamos y vuelve aquí.',
            icon: RomanzaSymbol.mail,
          ),
          if (session.identity?.email != null)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: RomanzaColors.of(context).note,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SelectableText(
                session.identity!.email!,
                style: RomanzaType.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          AuthPrimaryButton(
            label: 'Ya verifiqué mi correo',
            onPressed: session.busy ? null : session.checkVerification,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: session.busy || session.verificationCooldown > 0
                ? null
                : session.resendVerification,
            child: Text(
              session.verificationCooldown > 0
                  ? 'Reenviar en ${session.verificationCooldown} s'
                  : 'Reenviar correo',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¿No aparece? Revisa también la carpeta de spam.',
            style: RomanzaType.body.copyWith(
              color: RomanzaColors.of(context).secondary,
            ),
          ),
          AuthOperationStatus(session: session),
        ],
      ),
    ),
  );
}

class AuthRecoveryScreen extends StatelessWidget {
  const AuthRecoveryScreen({super.key, required this.session});
  final SessionController session;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: RomanzaPage(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Center(child: HeaderLogo()),
              const SizedBox(height: 24),
              Text(
                session.stage == SessionStage.disabled
                    ? 'Cuenta no disponible'
                    : 'No pudimos continuar',
                style: RomanzaType.section,
              ),
              const SizedBox(height: 16),
              Text(
                session.error ?? 'Comprueba tu conexión y vuelve a intentarlo.',
              ),
              const SizedBox(height: 24),
              if (session.stage != SessionStage.disabled)
                FilledButton(
                  onPressed: session.busy ? null : session.retry,
                  child: const Text('Reintentar'),
                ),
              TextButton(
                onPressed: session.busy ? null : session.signOut,
                child: const Text('Volver a bienvenida'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AuthOperationStatus extends StatelessWidget {
  const AuthOperationStatus({super.key, required this.session});
  final SessionController session;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (session.busy)
        const LinearProgressIndicator(semanticsLabel: 'Procesando acceso'),
      if (session.error != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              session.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      if (session.notice != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Semantics(liveRegion: true, child: Text(session.notice!)),
        ),
    ],
  );
}
