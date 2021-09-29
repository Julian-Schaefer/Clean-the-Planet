import 'package:flutter/material.dart';

import 'map_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Clean the Planet',
      home: MapView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
