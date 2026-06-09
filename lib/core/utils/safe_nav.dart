import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Shell-tab paths. Pushing one onto the root navigator stacks a duplicate
/// shell wrapper, which crashes Flutter's Navigator with a duplicate page key.
/// Always use [context.go] for these.
const _shellTabs = <String>{
  '/home',
  '/history',
  '/focus',
  '/insights-hub',
  '/profile',
};

/// Safe navigation helper. Use this instead of `context.push(...)` whenever the
/// route is supplied by data (insights, recommendations, narrative CTAs).
///
/// Behavior:
/// - If [route] is a shell tab, swap to it via `context.go` so the shell
///   navigator handles the transition.
/// - Otherwise, `context.push` it normally.
extension SafeNav on BuildContext {
  void wxNavigate(String route) {
    if (_shellTabs.contains(route)) {
      go(route);
    } else {
      push(route);
    }
  }
}
