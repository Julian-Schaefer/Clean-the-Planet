import 'package:flutter/material.dart';

import 'map_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.green,
        onPrimary: Colors.white,
        primaryVariant: Colors.white,
        secondary: Colors.lightGreen,
        secondaryVariant: Colors.white,
        onSecondary: Colors.white,
        background: Colors.grey,
        onBackground: Colors.grey,
        surface: Colors.grey,
        onSurface: Colors.grey,
        error: Colors.red,
        onError: Colors.white,
      )),
      title: 'Clean the Planet',
      home: const MapView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
