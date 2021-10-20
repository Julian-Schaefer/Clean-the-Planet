import 'dart:io';

import 'package:clean_the_planet/image_preview.dart';
import 'package:clean_the_planet/picture_screen.dart';
import 'package:clean_the_planet/take_picture_screen.dart';
import 'package:clean_the_planet/tour.dart';
import 'package:clean_the_planet/tour_picture.dart';
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
  final Duration duration;
  final List<TourPicture> tourPictures;

  const SummaryScreen(
      {Key? key,
      required this.finalLocation,
      required this.polylineCoordinates,
      required this.duration,
      required this.tourPictures})
      : super(key: key);

  @override
  State<SummaryScreen> createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
  late Polygon pathPolygon = Polygon(points: []);
  List<String> resultPictures = [];
  String? amount;

  @override
  void initState() {
    super.initState();
    _getTourBuffer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _navigateBackDialog();
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
                height: 360,
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
                    MarkerLayerOptions(markers: [
                      for (var picture in widget.tourPictures)
                        Marker(
                          width: 36.0,
                          height: 36.0,
                          anchorPos: AnchorPos.exactly(Anchor(18, 18)),
                          point: picture.location,
                          builder: (ctx) => const Icon(Icons.photo_camera,
                              size: 36.0, color: Colors.red),
                        )
                    ])
                  ],
                ),
              ),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Good job! You've done it.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )),
              const Divider(),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Duration:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500))),
              Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Text(Tour.getDurationString(widget.duration),
                      style: const TextStyle(fontSize: 18))),
              const Divider(),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Amount (in litres):",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter the amount in litres'),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  onChanged: (text) {
                    amount = text;
                  },
                ),
              ),
              const Divider(),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Add Pictures of the result:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500))),
              GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (var path in resultPictures)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PictureScreen(
                                  imagePath: path,
                                  heroTag: "picture_screen_" + path),
                            ));
                      },
                      child: Hero(
                          child: ImagePreview(
                            path: path,
                            onRemove: () async {
                              await File(path).delete();
                              setState(() {
                                resultPictures.remove(path);
                              });
                            },
                          ),
                          tag: "picture_screen_" + path),
                    ),
                  IconButton(
                      onPressed: addPicture,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 60.0))
                ],
              )
            ]),
          )),
    );
  }

  void _getTourBuffer() async {
    Polygon polygon = await TourService.getBuffer(widget.polylineCoordinates);
    setState(() {
      pathPolygon = polygon;
    });
  }

  void addTour() async {
    if (amount == null) {
      return;
    }

    Locale locale = Localizations.localeOf(context);

    Tour tour = Tour(
        polyline: widget.polylineCoordinates,
        duration: widget.duration,
        amount: Tour.toLocalDecimalAmount(amount!, locale),
        resultPictureKeys: resultPictures,
        tourPictures: widget.tourPictures);

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

  Future<bool> _navigateBackDialog() async {
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
