import 'dart:async';

import 'package:clean_the_planet/summary_screen.dart';
import 'package:clean_the_planet/timer_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Clean the Planet',
      home: MapView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  //final Completer<GoogleMapController> _controller = Completer();
  final TimerWidgetController _timerWidgetController = TimerWidgetController();
  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  final List<LatLng> _polylineCoordinates = [];
  //PolylinePoints polylinePoints;

  Location? _location;
  LocationData? _currentLocation;

  bool collectionStarted = false;

  static const defaultZoom = 18.0;

  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean the Planet'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(51.5, -0.09),
              zoom: defaultZoom,
              maxZoom: 18.4,
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              if (collectionStarted && _currentLocation != null)
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      point: LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      builder: (ctx) => const Icon(Icons.location_on_sharp,
                          size: 40.0, color: Colors.red),
                    ),
                  ],
                ),
              PolylineLayerOptions(
                polylines: [
                  Polyline(
                      points: _polylineCoordinates,
                      strokeWidth: 20.0,
                      color: Colors.red),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 20.0),
            child: Container(
              width: 170,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.green,
                boxShadow: const [
                  BoxShadow(color: Colors.grey, blurRadius: 5),
                ],
              ),
              child: Center(
                  child: TimerWidget(controller: _timerWidgetController)),
            ),
          )
        ],
      ),
      floatingActionButton: !collectionStarted
          ? FloatingActionButton.extended(
              onPressed: _startCollecting,
              label: const Text('Start collecting!'),
              icon: const Icon(Icons.shopping_bag),
              backgroundColor: Colors.green,
            )
          : FloatingActionButton.extended(
              onPressed: _finishCollecting,
              label: const Text('Finish collecting!'),
              icon: const Icon(Icons.shopping_bag),
              backgroundColor: Colors.red,
            ),
    );
  }

  void _startCollecting() {
    if (_location == null) {
      return;
    }

    _location!.enableBackgroundMode(enable: true);
    setState(() {
      collectionStarted = true;
      _timerWidgetController.startTimer!.call();
    });
  }

  void _finishCollecting() {
    if (_currentLocation == null ||
        _currentLocation!.latitude == null ||
        _currentLocation!.longitude == null ||
        _location == null) {
      return;
    }

    _location?.enableBackgroundMode(enable: false);

    setState(() {
      _timerWidgetController.stopTimer!.call();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SummaryScreen(
              markers: _markers,
              polylineCoordinates: _polylineCoordinates,
              finalLocation: _currentLocation!)),
    ).then((_) => setState(() {
          collectionStarted = false;
          _polylines.clear();
          _markers.clear();
          _polylineCoordinates.clear();
          _timerWidgetController.resetTimer!.call();
        }));
  }

  void _getInitialLocation() async {
    _location = Location();
    await _location?.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1500,
    );

    bool serviceEnabled = await _location!.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location!.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await _location!.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location!.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location!.getLocation();

    _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        _mapController.zoom);

    listenForLocationUpdates();
  }

  void listenForLocationUpdates() {
    _location!.onLocationChanged.listen((LocationData newLocation) {
      _updateRouteOnMap(newLocation);
    });
  }

  void _updateRouteOnMap(LocationData newLocation) async {
    if (newLocation.latitude == null || newLocation.longitude == null) {
      return;
    }

    var newPosition =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    _mapController.move(newPosition, defaultZoom);

    if (collectionStarted) {
      setState(() {
        _currentLocation = newLocation;
        _polylineCoordinates.add(newPosition);
      });
    }
  }
}
