import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidgetController {
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
  Duration duration = const Duration();
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
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final timeString = hours + ":" + minutes + ":" + seconds;
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
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);
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
      duration = const Duration();
    });
  }
}
