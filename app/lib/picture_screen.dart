import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PictureScreen extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final String heroTag;

  const PictureScreen(
      {Key? key, this.imagePath, this.imageUrl, required this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? body;

    if (imagePath != null) {
      body = Image.file(File(imagePath!));
    }

    if (imageUrl != null) {
      body = CachedNetworkImage(
          imageUrl: imageUrl!,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error));
    }

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
            child: Center(
                child: Hero(
          child: body!,
          tag: heroTag,
        ))));
  }
}
