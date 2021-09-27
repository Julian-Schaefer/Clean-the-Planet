import 'dart:async';

import 'package:clean_the_planet/take_picture_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:camera/camera.dart';

class SummaryScreen extends StatefulWidget {
  final CameraPosition finalLocation;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  const SummaryScreen(
      {Key? key,
      required this.finalLocation,
      required this.markers,
      required this.polylines})
      : super(key: key);

  @override
  State<SummaryScreen> createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Summary'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.terrain,
                myLocationButtonEnabled: false,
                initialCameraPosition: widget.finalLocation,
                markers: widget.markers,
                polylines: widget.polylines,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            const SizedBox(
              child: Text("Good job! You've done it."),
              height: 60,
            ),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  const Text("Add Photo"),
                  TextButton(
                      onPressed: () async {
                        final cameras = await availableCameras();
                        final firstCamera = cameras.first;

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TakePictureScreen(camera: firstCamera)));
                      },
                      child: const Text("Add Photo"))
                ],
              ),
            )
          ]),
        ));
  }
}
