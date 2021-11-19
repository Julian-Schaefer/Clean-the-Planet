import 'dart:io';

import 'package:clean_the_planet/image_preview.dart';
import 'package:clean_the_planet/picture_screen.dart';
import 'package:clean_the_planet/take_picture_screen.dart';
import 'package:clean_the_planet/tour.dart';
import 'package:clean_the_planet/tour_picture.dart';
import 'package:clean_the_planet/dialogs/tour_picture_dialog.dart';
import 'package:clean_the_planet/tour_service.dart';
import 'package:clean_the_planet/utils.dart';
import 'package:flutter/material.dart';
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
  bool _savingTourInProgress = false;
  final _formKey = GlobalKey<FormState>();

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
                    onPressed: !_savingTourInProgress ? addTour : null,
                    child: !_savingTourInProgress
                        ? Text(
                            "Save",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          )
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                    color: Theme.of(context).colorScheme.secondary,
                    disabledColor: Theme.of(context).colorScheme.secondary,
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
                          builder: (ctx) => GestureDetector(
                            onTap: () => _selectTourPicture(picture),
                            child: const Icon(Icons.photo_camera,
                                size: 36.0, color: Colors.red),
                          ),
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
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Amount (in litres):",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter the amount in litres'),
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                        onChanged: (text) {
                          amount = text;
                        },
                        validator: _validateAmount,
                      ),
                    ),
                  ],
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RawMaterialButton(
                      onPressed: addPicture,
                      elevation: 3.0,
                      fillColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 55.0,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  )
                ],
              )
            ]),
          )),
    );
  }

  void _getTourBuffer() async {
    try {
      Polygon polygon = await TourService.getBuffer(widget.polylineCoordinates);
      setState(() {
        pathPolygon = polygon;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, "Error: " + e.toString(), isError: true);
      }
    }
  }

  String? _validateAmount(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the amount.';
    }

    try {
      Locale locale = Localizations.localeOf(context);
      double amount = Tour.toLocalDecimalAmount(value, locale);

      if (amount <= 0) {
        throw Exception();
      }
    } catch (e) {
      return 'Please enter a valid number.';
    }
    return null;
  }

  void addTour() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _savingTourInProgress = true;
    });

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
      showSnackBar(context, 'Success! Tour has been saved.');
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

    setState(() {
      _savingTourInProgress = false;
    });
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
    List<String?>? result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TakePictureScreen()));

    if (result != null) {
      setState(() {
        resultPictures.add(result[0]!);
      });
    }
  }

  void _selectTourPicture(TourPicture tourPicture) async {
    await Navigator.of(context).push(
      TourPictureDialog(
          tourPicture: tourPicture,
          onDelete: () {
            Navigator.pop(context);
            setState(() {
              widget.tourPictures.remove(tourPicture);
            });
          }),
    );
  }
}
