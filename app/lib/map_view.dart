import 'dart:async';
import 'dart:io';

import 'package:clean_the_planet/menu_drawer.dart';
import 'package:clean_the_planet/summary_screen.dart';
import 'package:clean_the_planet/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:background_location/background_location.dart' as geo;

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  static const int interval = 1500;
  static const double distanceFilter = 5.0;

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
  void dispose() {
    geo.BackgroundLocation.stopLocationService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clean the Planet')),
      drawer: const MenuDrawer(),
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
                      width: 40.0,
                      height: 40.0,
                      anchorPos: AnchorPos.exactly(Anchor(20, 5)),
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
                color: Theme.of(context).colorScheme.primary,
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
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  void _startCollecting() {
    if (_currentLocation == null ||
        _currentLocation!.latitude == null ||
        _currentLocation!.longitude == null ||
        _location == null) {
      return;
    }

    if (Platform.isIOS) {
      _location!.enableBackgroundMode(enable: true);
    } else if (Platform.isAndroid) {
      _locationSubscription.cancel();
      _startAndroidBackgroundLocationService();
    }

    setState(() {
      collectionStarted = true;
      _timerWidgetController.startTimer!.call();

      _polylineCoordinates.add(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));
    });
  }

  void _finishCollecting() {
    if (_currentLocation == null ||
        _currentLocation!.latitude == null ||
        _currentLocation!.longitude == null ||
        _location == null) {
      return;
    }

    if (Platform.isIOS) {
      _locationSubscription.cancel();
      _location!.enableBackgroundMode(enable: false);
    } else if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }

    setState(() {
      collectionStarted = false;
      _timerWidgetController.stopTimer!.call();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SummaryScreen(
                polylineCoordinates: _polylineCoordinates,
                finalLocation: _currentLocation!,
                duration: _timerWidgetController.duration,
              )),
    ).then((_) => setState(() {
          _polylineCoordinates.clear();
          _timerWidgetController.resetTimer!.call();
          listenForLocationUpdates();
        }));
  }

  void _getInitialLocation() async {
    _location = Location();

    //TODO: Remove once fixed
    await Future.delayed(const Duration(seconds: 3));

    bool permissionsGranted = await askForLocationPermission();

    if (permissionsGranted) {
      await _location?.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: interval,
          distanceFilter: distanceFilter);

      listenForLocationUpdates();
    }
  }

  Future<bool> askForLocationPermission() async {
    bool serviceEnabled = await _location!.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location!.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location!.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location!.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  void _startAndroidBackgroundLocationService() async {
    geo.BackgroundLocation.setAndroidNotification(
      title: "Clean the Planet: Collecting",
      message: "We are using your location while you collect.",
      icon: "@mipmap/ic_launcher",
    );
    await geo.BackgroundLocation.setAndroidConfiguration(interval);
    geo.BackgroundLocation.startLocationService(distanceFilter: distanceFilter);
    geo.BackgroundLocation.getLocationUpdates((location) {
      _updateRouteOnMap(LocationData.fromMap(
          {"latitude": location.latitude, "longitude": location.longitude}));
    });
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

    var newLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);

    _mapController.move(newLatLng, defaultZoom);

    setState(() {
      _currentLocation = newLocation;
      if (collectionStarted) {
        _polylineCoordinates.add(newLatLng);
      }
    });
  }

  Widget _getFloatingActionButton() {
    if (_currentLocation == null) {
      return const FloatingActionButton.extended(
          onPressed: null,
          label: Text('Retrieving Location...'),
          icon: Icon(Icons.location_disabled));
    }

    if (!collectionStarted) {
      return FloatingActionButton.extended(
        onPressed: _startCollecting,
        label: const Text('Start collecting!'),
        icon: const Icon(Icons.map_outlined),
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      return FloatingActionButton.extended(
          onPressed: _finishCollecting,
          label: const Text('Finish collecting!'),
          icon: const Icon(Icons.map_outlined),
          backgroundColor: Theme.of(context).colorScheme.error);
    }
  }
}
