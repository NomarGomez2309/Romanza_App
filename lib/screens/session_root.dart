import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/couple_repository.dart';
import '../services/profile_repository.dart';
import '../session/session_controller.dart';

class SessionRoot extends StatefulWidget {
  const SessionRoot({super.key});
  @override
  State<SessionRoot> createState() => _SessionRootState();
}

class _SessionRootState extends State<SessionRoot> {
  late final AuthService _auth = AuthService();
  late final ProfileRepository _profiles = ProfileRepository();
  late final SessionController _session = SessionController(_auth, _profiles);
  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session,
    builder: (context, _) => _SessionPage(
      key: ValueKey('${_session.user?.uid}:${_session.stage}'),
      session: _session,
      auth: _auth,
      profiles: _profiles,
    ),
  );
}

class _SessionPage extends StatefulWidget {
  const _SessionPage({
    super.key,
    required this.session,
    required this.auth,
    required this.profiles,
  });
  final SessionController session;
  final AuthService auth;
  final ProfileRepository profiles;
  @override
  State<_SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<_SessionPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _accepted = false;
  String? _message;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      if (mounted && success != null) setState(() => _message = success);
    } catch (e) {
      if (mounted) {
        setState(
          () => _message = e is FirebaseFunctionsException
              ? e.message ?? 'No pudimos completar la operación.'
              : authErrorMessage(e),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _button(String label, Future<void> Function() action) => FilledButton(
    onPressed: _busy ? null : () => _run(action),
    child: Text(label),
  );
  Future<void> _open(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw StateError('No pudimos abrir el documento.');
    }
  }

  List<Widget> _content() {
    final s = widget.session;
    switch (s.stage) {
      case SessionStage.loading:
        return [
          const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Cargando sesión'),
          ),
        ];
      case SessionStage.welcome:
        return [
          Text(
            _register ? 'Crea tu cuenta' : 'Bienvenido a Romanza',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
            'Un espacio para compartir lo cotidiano, a vuestro ritmo.',
          ),
          _button('Continuar con Google', widget.auth.googleLogin),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            autofillHints: [
              _register ? AutofillHints.newPassword : AutofillHints.password,
            ],
            decoration: const InputDecoration(labelText: 'Contraseña'),
          ),
          if (_register)
            TextField(
              controller: _confirmation,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirma la contraseña',
              ),
            ),
          _button(_register ? 'Crear cuenta' : 'Entrar', () async {
            if (_email.text.trim().isEmpty || _password.text.isEmpty) {
              throw StateError('Completa correo y contraseña.');
            }
            if (_register && _password.text != _confirmation.text) {
              throw StateError('Las contraseñas no coinciden.');
            }
            if (_register) {
              await widget.auth.register(_email.text, _password.text);
            } else {
              await widget.auth.login(_email.text, _password.text);
            }
          }),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _register = !_register;
                    _message = null;
                  }),
            child: Text(_register ? 'Ya tengo una cuenta' : 'Crear una cuenta'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => _run(
                    () async {
                      if (_email.text.trim().isEmpty) {
                        throw StateError('Escribe tu correo primero.');
                      }
                      await widget.auth.resetPassword(_email.text);
                    },
                    success:
                        'Si corresponde, recibirás un correo para recuperar el acceso.',
                  ),
            child: const Text('Recuperar contraseña'),
          ),
        ];
      case SessionStage.verification:
        return [
          Text(
            'Verifica tu correo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Enviaremos el enlace a ${s.user?.email ?? 'tu correo'}. Después vuelve aquí.',
          ),
          _button('Enviar correo de verificación', () async {
            await widget.auth.sendVerification();
            if (mounted) {
              setState(
                () => _message =
                    'Correo enviado. Revisa también la carpeta de spam.',
              );
            }
          }),
          _button('Ya verifiqué mi correo', widget.auth.refreshVerification),
        ];
      case SessionStage.profile:
        return [
          Text(
            '¿Cómo te llamas?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
            'Este nombre se mostrará a tu pareja. Podrás cambiarlo después.',
          ),
          TextField(
            controller: _name,
            maxLength: 60,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          _button(
            'Continuar',
            () => widget.profiles.saveName(s.user!.uid, _name.text),
          ),
        ];
      case SessionStage.legalUnavailable:
        return [
          const Text(
            'Las condiciones de uso y la política de privacidad todavía no están disponibles.',
          ),
          const Text(
            'Podrás continuar cuando se publiquen los documentos vigentes.',
          ),
          _button('Reintentar', s.retry),
        ];
      case SessionStage.terms:
        final legal = s.legal!;
        return [
          Text(
            'Antes de continuar',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
            'Lee las condiciones de uso y la política de privacidad de Romanza.',
          ),
          _button('Condiciones de uso', () => _open(legal.termsUrl)),
          _button('Política de privacidad', () => _open(legal.privacyUrl)),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _accepted,
            onChanged: _busy
                ? null
                : (value) => setState(() => _accepted = value ?? false),
            title: const Text(
              'Acepto las condiciones de uso y he leído la política de privacidad.',
            ),
          ),
          FilledButton(
            onPressed: !_accepted || _busy
                ? null
                : () => _run(() => widget.profiles.acceptTerms(legal.version)),
            child: const Text('Aceptar y continuar'),
          ),
        ];
      case SessionStage.pairing:
        return [
          Text(
            'Conecta con tu pareja',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
            'Ambas personas confirmaréis el vínculo. También puedes hacerlo después.',
          ),
          _button('Mi Pareja', _openPairing),
          _button('Ahora no', () => widget.profiles.skipPairing(s.user!.uid)),
        ];
      case SessionStage.dashboard:
        return [
          Text(
            'Hoy, contigo',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text('Hola, ${s.profile!.displayName}'),
          Text(
            s.profile!.coupleId == null
                ? 'Aún no hay una pareja vinculada.'
                : 'Tu pareja está vinculada.',
          ),
          if (s.profile!.fromCache)
            const Text(
              'Mostrando información guardada. Puede estar sin actualizar.',
            ),
          _button('Mi Pareja', _openPairing),
          _button('Vincular acceso con Google', widget.auth.linkGoogle),
          const Text(
            'La base de cuenta y pareja está lista. Los módulos de fotos, planes y recuerdos se incorporarán por separado.',
          ),
        ];
      case SessionStage.error:
        return [
          Text(s.error ?? 'No pudimos cargar tu sesión.'),
          _button('Reintentar', s.retry),
        ];
    }
  }

  Future<void> _openPairing() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PairingPage(
          session: widget.session,
          repository: CoupleRepository(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Romanza'),
      actions: [
        if (widget.session.user != null)
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _busy ? null : () => _run(widget.auth.signOut),
            icon: const Icon(Icons.logout),
          ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final item in _content())
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: item,
                ),
              if (_busy) const LinearProgressIndicator(),
              if (_message != null) Text(_message!, semanticsLabel: _message),
            ],
          ),
        ),
      ),
    ),
  );
}

class PairingPage extends StatefulWidget {
  const PairingPage({
    super.key,
    required this.session,
    required this.repository,
  });
  final SessionController session;
  final CoupleRepository repository;
  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final _token = TextEditingController();
  late final String? _initialUid;
  String? _createdToken;
  String? _inviteId;
  String? _message;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _initialUid = widget.session.user?.uid;
    widget.session.addListener(_changed);
  }

  void _changed() {
    if (!mounted) return;
    if (widget.session.user?.uid != _initialUid) {
      _createdToken = null;
      _inviteId = null;
      _message = null;
      _token.clear();
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.session.removeListener(_changed);
    _token.dispose();
    super.dispose();
  }

  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        _message = e is FirebaseFunctionsException
            ? e.message
            : authErrorMessage(e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _button(String label, Future<void> Function() action) => FilledButton(
    onPressed: _busy ? null : () => _run(action),
    child: Text(label),
  );
  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    // Do not leave a previously pushed route visible after logout or a policy change.
    final allowed =
        s.user?.uid == _initialUid &&
        s.user?.verified == true &&
        [SessionStage.pairing, SessionStage.dashboard].contains(s.stage);
    final coupleId = s.profile?.coupleId;
    final inviteId = s.profile?.activeInviteId ?? _inviteId;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Pareja')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (!allowed)
              const Text('Vuelve al inicio para continuar con tu sesión.')
            else if (coupleId != null) ...[
              StreamBuilder<Map<String, dynamic>?>(
                stream: widget.repository.watchCouple(coupleId),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Text(
                      'No pudimos cargar el vínculo. Revisa tu conexión.',
                    );
                  }
                  final profiles = snap.data?['profiles'] as Map?;
                  final partner = profiles?[s.profile?.partnerId] as Map?;
                  return Text(
                    partner?['displayName'] as String? ?? 'Pareja vinculada',
                  );
                },
              ),
              _button('Desvincularme', () async {
                if (await _confirm(
                  '¿Desvincular pareja?',
                  'Se cerrará el acceso compartido para ambos. Cerrar sesión no produce este cambio.',
                )) {
                  await widget.repository.unlink();
                }
              }),
            ] else ...[
              const Text(
                'Invita a tu pareja. El código caduca en 15 minutos y ambos confirmaréis antes de vincular las cuentas.',
              ),
              _button('Crear invitación', () async {
                final invite = await widget.repository.createInvite();
                if (!mounted) return;
                setState(() {
                  _createdToken = invite['token'] as String;
                  _inviteId = invite['inviteId'] as String;
                });
              }),
              if (_createdToken != null) ...[
                SelectableText(_createdToken!),
                _button('Copiar invitación', () async {
                  await Clipboard.setData(ClipboardData(text: _createdToken!));
                }),
              ],
              if (inviteId != null)
                StreamBuilder<Map<String, dynamic>?>(
                  stream: widget.repository.watchInvite(inviteId),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return const Text('No pudimos cargar la invitación.');
                    }
                    final invite = snap.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${invite?['status'] ?? 'cargando'}'),
                        if (invite?['status'] == 'requested')
                          _button(
                            'Confirmar a ${invite?['candidateName']}',
                            () async {
                              if (await _confirm(
                                'Confirmar pareja',
                                '¿Quieres vincular tu cuenta con ${invite?['candidateName']}?',
                              )) {
                                await widget.repository.confirm(inviteId);
                              }
                            },
                          ),
                        if (invite?['status'] == 'open' ||
                            invite?['status'] == 'requested')
                          _button(
                            'Revocar invitación',
                            () => widget.repository.revoke(inviteId),
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 24),
              TextField(
                controller: _token,
                decoration: const InputDecoration(labelText: 'Código recibido'),
              ),
              _button('Revisar invitación', () async {
                final token = _token.text.trim();
                final preview = await widget.repository.preview(token);
                if (!mounted) return;
                if (await _confirm(
                  'Invitación de ${preview['ownerName']}',
                  'Enviarás una solicitud. La otra persona tendrá que confirmarla.',
                )) {
                  await widget.repository.request(token);
                  if (mounted) {
                    setState(
                      () => _message =
                          'Solicitud enviada. Esperando la confirmación de tu pareja.',
                    );
                  }
                }
              }),
            ],
            if (_busy) const LinearProgressIndicator(),
            if (_message != null) Text(_message!),
          ],
        ),
      ),
    );
  }
}
