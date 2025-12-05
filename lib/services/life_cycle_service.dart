import 'package:flutter/material.dart';

enum AppStatus { paused, active, detached, inactive }

class LifeCycleService extends ChangeNotifier {
  AppStatus appStatus = AppStatus.active;
  static final LifeCycleService _instance = LifeCycleService._internal();

  LifeCycleService._internal();

  factory LifeCycleService() {
    return _instance;
  }

  setAppStatus(AppStatus newAppStatus) {
    appStatus = newAppStatus;
  }

  getAppStatus() {
    return appStatus;
  }
}
