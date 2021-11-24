import 'package:clean_the_planet/image_preview.dart';
import 'package:clean_the_planet/tour_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourPictureDialog extends PopupRoute {
  final TourPicture tourPicture;
  final VoidCallback? onDelete;

  TourPictureDialog({required this.tourPicture, this.onDelete}) : super();

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => true;

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
            const EdgeInsets.only(top: 140, bottom: 100, left: 20, right: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              color: Colors.white.withOpacity(1),
              child: Column(children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ImagePreview(
                          path: tourPicture.imageKey!,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tourPicture.comment != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.comment,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tourPicture.comment!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
              ]),
            ),
            Positioned(
              right: -32,
              top: -16,
              child: RawMaterialButton(
                onPressed: onDelete,
                elevation: 2.0,
                fillColor: Colors.red.shade800,
                child: const Icon(
                  Icons.delete,
                  size: 30,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(10.0),
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
