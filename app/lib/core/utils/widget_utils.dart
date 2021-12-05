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
