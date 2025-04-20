import 'package:flutter/material.dart';
import 'package:skin_shine/services/supabase_service.dart';

class ActivityObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateActivity();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateActivity();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateActivity();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateActivity();
    super.didRemove(route, previousRoute);
  }

  void _updateActivity() {
    // Cập nhật thời gian hoạt động khi có thay đổi điều hướng
    SupabaseService.updateUserActivity();
  }
}

class UserActivityDetector extends StatelessWidget {
  final Widget child;

  const UserActivityDetector({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => SupabaseService.updateUserActivity(),
      onPointerMove: (_) => SupabaseService.updateUserActivity(),
      child: child,
    );
  }
} 