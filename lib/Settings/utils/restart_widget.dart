import 'package:everqpidapp/Settings/helper/app_start_router.dart';
import 'package:everqpidapp/Settings/utils/app_navigator.dart';
import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  /// Call this anywhere to restart app state.
  static void restartApp(BuildContext context) async {
    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restart();

    final route = await AppStartRouter.resolve();
    AppNavigator.pushNamedAndRemoveUntil(route, (r) => false);
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
