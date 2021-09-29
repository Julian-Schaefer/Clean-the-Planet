import 'package:clean_the_planet/take_picture_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'calculate_polygon.dart';

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
  late Polygon pathPolygon;

  @override
  void initState() {
    super.initState();
    pathPolygon = Polygon(
        points: calculatePolygonFromPath(widget.polylineCoordinates),
        color: Colors.red.withOpacity(0.6));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? navigateBack = await navigateBackDialog();
        if (navigateBack != null) {
          return navigateBack;
        }

        return false;
      },
      child: Scaffold(
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
                    // MarkerLayerOptions(
                    //   markers: [
                    //     Marker(
                    //       point: LatLng(widget.finalLocation.latitude!,
                    //           widget.finalLocation.longitude!),
                    //       builder: (ctx) => const Icon(Icons.location_pin,
                    //           size: 40.0, color: Colors.red),
                    //     ),
                    //   ],
                    // ),
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
          )),
    );
  }

  Future<bool?> navigateBackDialog() async {
    return showDialog<bool>(
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
  }
}
