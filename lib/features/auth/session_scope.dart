import 'package:flutter/widgets.dart';
import 'session_controller.dart';

/// The same live session drives setup and account editing; a pushed route never
/// creates another Firebase identity or stores credentials of its own.
class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController session,
    required super.child,
  }) : super(notifier: session);
  static SessionController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;
}
