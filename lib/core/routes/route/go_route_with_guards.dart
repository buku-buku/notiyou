import 'package:go_router/go_router.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';

class GoRouteWithGuards extends GoRoute {
  final List<RouteGuard> guards;

  GoRouteWithGuards({
    required super.path,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes = const <RouteBase>[],
    required this.guards,
  });
}
