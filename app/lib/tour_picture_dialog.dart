import 'package:clean_the_planet/image_preview.dart';
import 'package:clean_the_planet/tour_picture.dart';
import 'package:flutter/material.dart';

class TourPictureDialog extends PopupRoute {
  final TourPicture tourPicture;

  TourPictureDialog({required this.tourPicture}) : super();

  @override
  Color get barrierColor => Colors.black.withOpacity(0.4);

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
            const EdgeInsets.only(top: 140, bottom: 80, left: 15, right: 15),
        child: Card(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {},
                    color: Colors.black,
                    icon: const Icon(Icons.edit)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete))
              ],
            ),
            Expanded(
              child: ImagePreview(
                path: tourPicture.imageKey!,
              ),
            ),
            if (tourPicture.comment != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Comment: " + tourPicture.comment!,
                  style: const TextStyle(fontSize: 16),
                ),
              )
          ]),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
