import 'dart:io';

import 'package:clean_the_planet/take_picture_screen.dart';
import 'package:clean_the_planet/tour.dart';
import 'package:clean_the_planet/tour_service.dart';
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
  late Polygon pathPolygon = Polygon(points: []);
  List<String> resultPictures = [];

  @override
  void initState() {
    super.initState();
    getTourBuffer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await navigateBackDialog();
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Summary'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: MaterialButton(
                    onPressed: addTour,
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: ListView(children: [
              SizedBox(
                height: 300,
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
                    PolygonLayerOptions(polygons: [pathPolygon]),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                            points: widget.polylineCoordinates,
                            strokeWidth: 2.0,
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
              GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (var path in resultPictures) Image.file(File(path)),
                  const Icon(Icons.photo, size: 60.0)
                ],
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    const Text("Add Picture"),
                    TextButton(
                        onPressed: addPicture, child: const Text("Add Picture"))
                  ],
                ),
              )
            ]),
          )),
    );
  }

  void getTourBuffer() async {
    List<LatLng> polygon =
        await TourService.getBuffer(widget.polylineCoordinates);
    setState(() {
      pathPolygon =
          Polygon(points: polygon, color: Colors.red.withOpacity(0.6));
    });
  }

  void addTour() async {
    Tour tour = Tour(
        polyline: widget.polylineCoordinates, resultPictureKeys: resultPictures);
    try {
      await TourService.addTour(tour);
      Navigator.pop(context);
    } catch (e) {
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(e.toString()),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    )
                  ]));
    }
  }

  Future<bool> navigateBackDialog() async {
    bool? navigateBack = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text(
                  'If you navigate back now, your tour will be lost. Do you want to continue?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () => Navigator.pop(context, true),
                  color: Colors.red,
                  child: const Text(
                    'Discard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ));

    if (navigateBack != null) {
      return navigateBack;
    }

    return false;
  }

  void addPicture() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    String? imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: firstCamera)));

    if (imagePath != null) {
      setState(() {
        resultPictures.add(imagePath);
      });
    }
  }
}
