import 'package:flutter/material.dart';
import '../../design_system/components.dart';
import '../../design_system/header_logo.dart';
import '../../design_system/romanza_theme.dart';
import 'session_controller.dart';
import '../settings/legal_draft_screen.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key, required this.session});
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
              const SizedBox(height: 64),
              SizedBox(
                height: 64,
                child: Center(
                  child: Transform.scale(scale: 2, child: const HeaderLogo()),
                ),
              ),
              const SizedBox(height: 40),
              Text('Sus momentos, más cerca', style: RomanzaType.greeting),
              const SizedBox(height: 12),
              Text(
                'Un espacio para compartir lo cotidiano y guardar lo que importa.',
                style: RomanzaType.body.copyWith(fontSize: 16, height: 24 / 16),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: session.busy ? null : session.google,
                child: const Text('Continuar con Google'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: session.busy
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EmailAccessScreen(
                            session: session,
                            mode: EmailAccessMode.register,
                          ),
                        ),
                      ),
                child: const Text('Continuar con correo'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: session.busy
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EmailAccessScreen(
                            session: session,
                            mode: EmailAccessMode.login,
                          ),
                        ),
                      ),
                child: const Text('Iniciar sesión'),
              ),
              AuthOperationStatus(session: session),
              const SizedBox(height: 24),
              Text(
                'Romanza es para mayores de 18 años.',
                style: RomanzaType.caption,
                textAlign: TextAlign.center,
              ),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
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
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          top: false,
          child: RomanzaPage(
            child: Form(
              key: form,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const ValueKey('auth-email'),
                      controller: email,
                      enabled: !busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
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
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: TextButton(
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
                          decoration: const InputDecoration(
                            labelText: 'Confirmar contraseña',
                          ),
                          validator: (value) =>
                              value == password.text && value!.isNotEmpty
                              ? null
                              : 'Las contraseñas deben coincidir.',
                        ),
                      ],
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: busy ? null : submit,
                      child: Text(
                        mode == EmailAccessMode.reset
                            ? 'Enviar instrucciones'
                            : title,
                      ),
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
              Text('Revisa tu correo', style: RomanzaType.greeting),
              const SizedBox(height: 16),
              Text(
                'Confirma tu correo con el enlace de verificación. Si no lo tienes, puedes solicitarlo aquí.',
                style: RomanzaType.body,
              ),
              if (session.identity?.email != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SelectableText(session.identity!.email!),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: session.busy ? null : session.checkVerification,
                child: const Text('Ya verifiqué mi correo'),
              ),
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
              TextButton(
                onPressed: session.busy ? null : session.signOut,
                child: const Text('Usar otra cuenta'),
              ),
              AuthOperationStatus(session: session),
            ],
          ),
        ),
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
