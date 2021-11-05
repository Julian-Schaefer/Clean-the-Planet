import 'package:flutter/material.dart';

class SamsungBatteryHelpDialog extends PopupRoute {
  final VoidCallback onComplete;

  SamsungBatteryHelpDialog({required this.onComplete}) : super();

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => "";

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Transform.scale(
      scale: animation.value,
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 120, bottom: 80, left: 20, right: 20),
        child: Card(
          color: Colors.white.withOpacity(1),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("This is a Samsung. Nothing to do :)"),
            const SizedBox(height: 32),
            MaterialButton(
              onPressed: onComplete,
              color: Theme.of(context).colorScheme.primary,
              child: const Text("Acknowledge",
                  style: TextStyle(color: Colors.white)),
            )
          ]),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
