import 'package:flutter/material.dart';
import '../../design_system/header_logo.dart';
import '../../design_system/romanza_theme.dart';
import 'auth_repository.dart';
import 'session_controller.dart';
import 'auth_screens.dart';
import 'profile_setup_screen.dart';
import 'session_scope.dart';

/// Replacing this nested navigator destroys forms and private routes on a UID or
/// session-stage change, including when sign-out occurs in a pushed settings page.
class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.repository,
    required this.authenticated,
  });
  final AuthRepository repository;
  final WidgetBuilder authenticated;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  late final SessionController session;
  GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
  String? routeIdentity;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    session = SessionController(widget.repository);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) session.resume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      final identity = '${session.identity?.uid}:${session.stage.name}';
      if (routeIdentity != identity) {
        routeIdentity = identity;
        navigator = GlobalKey<NavigatorState>();
      }
      return SessionScope(
        session: session,
        child: NavigatorPopHandler<Object?>(
          onPopWithResult: (_) => navigator.currentState?.pop(),
          child: Navigator(
            key: navigator,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => switch (session.stage) {
                SessionStage.welcome => AuthWelcomeScreen(session: session),
                SessionStage.verification => EmailVerificationScreen(
                  session: session,
                ),
                SessionStage.profile => ProfileSetupScreen(session: session),
                SessionStage.authenticated => widget.authenticated(context),
                SessionStage.loading => const AuthLoadingScreen(),
                SessionStage.error ||
                SessionStage.disabled => AuthRecoveryScreen(session: session),
              },
            ),
          ),
        ),
      );
    },
  );
}

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeaderLogo(),
            const SizedBox(height: 24),
            Text('Preparando sus momentos', style: RomanzaType.body),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              semanticsLabel: 'Recuperando sesión',
            ),
          ],
        ),
      ),
    ),
  );
}
