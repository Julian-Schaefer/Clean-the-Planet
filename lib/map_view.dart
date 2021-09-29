import 'dart:async';

import 'package:clean_the_planet/calculate_polygon.dart';
import 'package:clean_the_planet/summary_screen.dart';
import 'package:clean_the_planet/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final TimerWidgetController _timerWidgetController = TimerWidgetController();
  final List<LatLng> _polylineCoordinates = [];

  late StreamSubscription<LocationData> _locationSubscription;

  Location? _location;
  LocationData? _currentLocation;

  bool collectionStarted = false;

  static const defaultZoom = 18.0;

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
                      builder: (ctx) => const Icon(Icons.location_pin,
                          size: 40.0, color: Colors.red),
                    ),
                  ],
                ),
              PolylineLayerOptions(
                polylines: [
                  Polyline(
                      points: _polylineCoordinates,
                      strokeWidth: 4.0,
                      borderStrokeWidth: 16.0,
                      borderColor: Colors.redAccent.withOpacity(0.5),
                      color: Colors.red.withOpacity(0.8)),
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

    _locationSubscription.cancel();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SummaryScreen(
              polylineCoordinates: _polylineCoordinates,
              finalLocation: _currentLocation!)),
    ).then((_) => setState(() {
          collectionStarted = false;
          _polylineCoordinates.clear();
          _timerWidgetController.resetTimer!.call();
          listenForLocationUpdates();
        }));
  }

  void _getInitialLocation() async {
    _location = Location();
    await _location?.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1500,
    );

    await askForLocationPermission();

    _currentLocation = await _location!.getLocation();

    _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        _mapController.zoom);

    listenForLocationUpdates();
  }

  Future<void> askForLocationPermission() async {
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
  }

  void listenForLocationUpdates() {
    _locationSubscription =
        _location!.onLocationChanged.listen((LocationData newLocation) {
      _updateRouteOnMap(newLocation);
    });
  }

  void _updateRouteOnMap(LocationData newLocation) async {
    if (newLocation.latitude == null || newLocation.longitude == null) {
      return;
    }

    var currentLatLng =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    _mapController.move(currentLatLng, defaultZoom);

    if (collectionStarted) {
      bool addLatLng = false;
      if (_polylineCoordinates.isNotEmpty) {
        LatLng lastLatLng = _polylineCoordinates.last;
        addLatLng = checkNecessaryDistance(lastLatLng, currentLatLng);
      } else {
        addLatLng = true;
      }

      if (addLatLng) {
        setState(() {
          _currentLocation = newLocation;
          _polylineCoordinates.add(currentLatLng);
        });
      }
    }
  }
}
