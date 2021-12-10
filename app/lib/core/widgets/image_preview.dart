import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/services/picture_service.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  final String? pictureKey;
  final String? imagePath;
  final BoxDecoration? decoration;

  const ImageWidget(
      {Key? key, this.pictureKey, this.imagePath, this.decoration})
      : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  late Future<String> imageUrl;
  PictureService pictureService = getIt<PictureService>();

  @override
  void initState() {
    getImageUrl();
    super.initState();
  }

  void getImageUrl() async {
    setState(() {
      if (widget.pictureKey != null) {
        imageUrl = pictureService.getPictureUrl(widget.pictureKey!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath != null) {
      return getImage(Image.file(File(widget.imagePath!)).image);
    }

    return FutureBuilder<String>(
        future: imageUrl,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return CachedNetworkImage(
                imageUrl: snapshot.data!,
                imageBuilder: (context, imageProvider) =>
                    getImage(imageProvider),
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) {
                  return const Center(child: Icon(Icons.error));
                });
          }
        });
  }

  Widget getImage(ImageProvider imageProvider) {
    return Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: (widget.decoration != null)
              ? widget.decoration!.borderRadius
              : null,
          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
        ),
        decoration: widget.decoration);
  }
}

class ImagePreview extends StatelessWidget {
  final String? pictureKey;
  final String? imagePath;
  final VoidCallback? onRemove;

  const ImagePreview({Key? key, this.pictureKey, this.imagePath, this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ImageWidget(
            pictureKey: pictureKey,
            imagePath: imagePath,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade900,
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ]),
          ),
        ),
        if (onRemove != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () {
                  onRemove!();
                },
                icon: const Icon(
                  Icons.highlight_remove,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
