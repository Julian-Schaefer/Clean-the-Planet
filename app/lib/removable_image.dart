import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImagePreview extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onRemove;

  const NetworkImagePreview({Key? key, required this.imageUrl, this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(color: Colors.green.shade900, spreadRadius: 1),
                ],
              ),
            ),
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
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

class ImagePreview extends StatelessWidget {
  final String path;
  final VoidCallback? onRemove;

  const ImagePreview({Key? key, required this.path, this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.green.shade900, spreadRadius: 1),
              ],
              image: DecorationImage(
                  image: Image.file(File(path)).image, fit: BoxFit.fill),
            ),
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
