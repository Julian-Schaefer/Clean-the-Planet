import 'dart:async';

import 'package:clean_the_planet/summary_screen.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  final List<LatLng> _polylineCoordinates = [];
  //PolylinePoints polylinePoints;

  Location? _location;
  LocationData? _currentLocation;

  bool collectionStarted = false;

  static const defaultZoom = 18.0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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
          GoogleMap(
            mapType: MapType.terrain,
            myLocationButtonEnabled: false,
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _getInitialLocation();
            },
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
              child: const Center(
                  child: Text(
                "00:00",
                style: TextStyle(fontSize: 26, color: Colors.white),
              )),
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

    CameraPosition finalLocation = CameraPosition(
      zoom: defaultZoom,
      target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SummaryScreen(
              markers: _markers,
              polylines: _polylines,
              finalLocation: finalLocation)),
    ).then((_) => setState(() {
          collectionStarted = false;
          _polylines.clear();
          _markers.clear();
          _polylineCoordinates.clear();
        }));
  }

  void _getInitialLocation() async {
    _location = Location();

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

    final GoogleMapController controller = await _controller.future;

    LocationData locationData = await _location!.getLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: defaultZoom)));

    listenForLocationUpdates();
  }

  void listenForLocationUpdates() {
    _location!.onLocationChanged.listen((LocationData currentLocation) {
      _currentLocation = currentLocation;
      _updatePinOnMap();
    });
  }

  void _updatePinOnMap() async {
    if (_currentLocation == null ||
        _currentLocation!.latitude == null ||
        _currentLocation!.longitude == null) {
      return;
    }

    var newPosition =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    CameraPosition currentPosition = CameraPosition(
      zoom: defaultZoom,
      target: newPosition,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "sourcePin");

      if (collectionStarted) {
        _polylineCoordinates.add(newPosition);

        _polylines.clear();
        _polylines.add(Polyline(
            width: 10, // set the width of the polylines
            polylineId: const PolylineId("poly"),
            color: const Color.fromARGB(255, 40, 122, 198),
            points: _polylineCoordinates));

        _markers.add(Marker(
            markerId: const MarkerId("sourcePin"), position: newPosition));
      }
    });
  }
}
