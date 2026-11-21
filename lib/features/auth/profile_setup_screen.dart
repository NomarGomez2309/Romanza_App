import 'package:flutter/material.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';
import 'auth_design.dart';
import 'auth_screens.dart';
import 'session_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.session});
  final SessionController session;
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!widget.session.busy && _form.currentState!.validate()) {
      await widget.session.saveName(_name.text);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.session,
    builder: (context, _) => AuthPageLayout(
      footer: TextButton(
        onPressed: widget.session.busy ? null : widget.session.signOut,
        child: const Text('Usar otra cuenta'),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrand(),
            const SizedBox(height: 48),
            const AuthIntro(
              title: '¿Cómo te llamas?',
              subtitle:
                  'Un nombre para este espacio que van a compartir. Puedes cambiarlo después desde tu cuenta.',
              icon: RomanzaSymbol.userRound,
            ),
            TextFormField(
              key: const ValueKey('profile-name'),
              controller: _name,
              enabled: !widget.session.busy,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.nickname],
              textInputAction: TextInputAction.done,
              decoration: authFieldDecoration(
                context,
                'Tu nombre',
                hint: 'Como te gusta que te llamen',
              ),
              onFieldSubmitted: (_) => _save(),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Escribe tu nombre para continuar.'
                  : null,
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Entrar a Romanza',
              onPressed: widget.session.busy ? null : _save,
            ),
            const SizedBox(height: 16),
            Text(
              'Puedes explorar Romanza sin vincular una pareja.',
              textAlign: TextAlign.center,
              style: RomanzaType.body.copyWith(
                color: RomanzaColors.of(context).secondary,
              ),
            ),
            AuthOperationStatus(session: widget.session),
          ],
        ),
      ),
    ),
  );
}
