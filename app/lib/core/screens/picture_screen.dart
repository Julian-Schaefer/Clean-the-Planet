import 'dart:io';

import 'package:clean_the_planet/core/widgets/image_preview.dart';
import 'package:flutter/material.dart';

class PictureScreen extends StatelessWidget {
  final String? imagePath;
  final String? pictureKey;
  final String heroTag;

  const PictureScreen(
      {Key? key, this.imagePath, this.pictureKey, required this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? body;

    if (imagePath != null) {
      body = Image.file(File(imagePath!));
    }

    if (pictureKey != null) {
      body = ImageWidget(pictureKey: pictureKey!);
    }

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
            child: LayoutBuilder(
          builder: (context, constraints) => Draggable(
            feedback: SizedBox(
              child: body!,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            childWhenDragging: Container(),
            child: Center(
                child: Hero(
              child: body,
              tag: heroTag,
            )),
            onDragEnd: (details) {
              if (details.offset.distance > constraints.maxWidth / 2) {
                Navigator.pop(context);
              }
            },
          ),
        )));
  }
}
