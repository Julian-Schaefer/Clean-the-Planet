import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {isError = false}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    backgroundColor: (!isError)
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool> showConfirmDialog(BuildContext context,
    {String? title,
    String? content,
    String? noAction,
    String? yesAction}) async {
  bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(title!),
            content: Text(content!),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(noAction!),
              ),
              MaterialButton(
                onPressed: () => Navigator.pop(context, true),
                color: Colors.red,
                child: Text(
                  yesAction!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ));

  return confirmed != null && confirmed;
}
