import 'package:flutter/material.dart';
import '../services/life_cycle_service.dart';
import '../utils/auth_store.dart';
import '../utils/socket_services.dart';

class LifeCycle extends StatefulWidget {
  const LifeCycle({super.key, required this.child});

  final Widget child;

  @override
  State<LifeCycle> createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    try {
      switch (state) {
        case AppLifecycleState.paused:
          LifeCycleService().setAppStatus(AppStatus.paused);
          break;
        case AppLifecycleState.resumed:
          LifeCycleService().setAppStatus(AppStatus.active);
          try {
            if (await AuthStore().isValidationNeeded()) {
              AuthStore().validateToken();
            }
            SocketServices().startSocketConnection();
          } catch (e) {
            // logger.error(e.toString());
          }
          break;
        case AppLifecycleState.detached:
          LifeCycleService().setAppStatus(AppStatus.detached);
          break;
        case AppLifecycleState.inactive:
          LifeCycleService().setAppStatus(AppStatus.inactive);
          break;
        default:
          break;
      }
    } catch (e) {
      // logger.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
