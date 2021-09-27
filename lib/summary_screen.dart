import 'package:clean_the_planet/take_picture_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class SummaryScreen extends StatefulWidget {
  final LocationData finalLocation;
  final List<LatLng> polylineCoordinates;

  const SummaryScreen(
      {Key? key,
      required this.finalLocation,
      required this.polylineCoordinates})
      : super(key: key);

  @override
  State<SummaryScreen> createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
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
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(widget.finalLocation.latitude!,
                      widget.finalLocation.longitude!),
                  zoom: 18.0,
                  maxZoom: 18.4,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        point: LatLng(widget.finalLocation.latitude!,
                            widget.finalLocation.longitude!),
                        builder: (ctx) => const Icon(Icons.location_pin,
                            size: 40.0, color: Colors.red),
                      ),
                    ],
                  ),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                          points: widget.polylineCoordinates,
                          strokeWidth: 4.0,
                          borderStrokeWidth: 26.0,
                          borderColor: Colors.redAccent.withOpacity(0.5),
                          color: Colors.red),
                    ],
                  ),
                ],
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
