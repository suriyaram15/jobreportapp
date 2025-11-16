import 'dart:async';
import 'package:flutter/foundation.dart';

const Duration idleTimeout = Duration(minutes: 5);

class TimerService {
  Timer? _timer;
  DateTime _lastActivity = DateTime.now();
  bool _isIdle = false;

  DateTime get lastActivityTime => _lastActivity;

  void start(void Function(bool) onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final idleTime = now.difference(_lastActivity);

      bool wokeFromSleep = false;
      if (idleTime > idleTimeout) {
        if (!_isIdle) {
          _isIdle = true;
          wokeFromSleep = true;
        }
      } else {
        _isIdle = false;
      }

      onTick(wokeFromSleep);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void recordActivity() {
    _lastActivity = DateTime.now();
  }
}
