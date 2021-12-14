import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clean_the_planet/core/data/extensions/extensions.dart';

class TimerWidgetController {
  Duration duration = const Duration();
  VoidCallback? startTimer;
  VoidCallback? stopTimer;
  VoidCallback? resetTimer;

  void dispose() {
    startTimer = null;
    stopTimer = null;
    resetTimer = null;
  }
}

class TimerWidget extends StatefulWidget {
  final TimerWidgetController controller;

  const TimerWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    resetTimer();

    var _controller = widget.controller;
    _controller.startTimer = startTimer;
    _controller.stopTimer = stopTimer;
    _controller.resetTimer = resetTimer;
  }

  @override
  Widget build(BuildContext context) {
    final timeString = widget.controller.duration.getDurationString();
    return Text(timeString,
        style: const TextStyle(fontSize: 26, color: Colors.white));
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    setState(() {
      Duration duration = widget.controller.duration;
      final seconds = duration.inSeconds + 1;
      widget.controller.duration = Duration(seconds: seconds);
    });
  }

  void stopTimer() {
    setState(() => timer!.cancel());
  }

  void resetTimer() {
    setState(() {
      if (timer != null && timer!.isActive) {
        timer!.cancel();
      }
      widget.controller.duration = const Duration();
    });
  }
}
