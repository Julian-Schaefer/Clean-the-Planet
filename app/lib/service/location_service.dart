import 'dart:async';
import 'dart:io';

import 'package:background_location/background_location.dart' as geo;
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/service/permission_service.dart';
import 'package:location/location.dart';

class LocationService {
  static const int interval = 1500;
  static const double distanceFilter = 5.0;

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  final PermissionService permissionService = getIt<PermissionService>();

  final StreamController<LocationData> _locationStreamController =
      StreamController<LocationData>();
  late Stream<LocationData> onLocationChanged;

  LocationService() {
    onLocationChanged = _locationStreamController.stream;
  }

  Future<void> close() async {
    await _locationSubscription?.cancel();
    if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }
  }

  Future<void> getInitialLocation() async {
    //TODO: Remove once fixed
    await Future<void>.delayed(const Duration(seconds: 2));

    bool permissionsGranted =
        await permissionService.askForLocationPermission(_location);

    if (permissionsGranted) {
      await _location.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: interval,
          distanceFilter: distanceFilter);

      LocationData initialLocation = await getCurrentLocation();
      _broadcastLocation(initialLocation);
      listenForLocationUpdates();
    }
  }

  Future<LocationData> getCurrentLocation() async {
    LocationData refreshedLocation = await _location.getLocation();
    return refreshedLocation;
  }

  void listenForLocationUpdates() {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData newLocation) {
      _broadcastLocation(newLocation);
    });
  }

  Future<void> startCollecting() async {
    if (Platform.isIOS) {
      _location.enableBackgroundMode(enable: true);
    } else if (Platform.isAndroid) {
      await _locationSubscription!.cancel();
      _startAndroidBackgroundLocationService();
    }
  }

  Future<void> finishCollecting() async {
    if (Platform.isIOS) {
      await _locationSubscription!.cancel();
      _location.enableBackgroundMode(enable: false);
    } else if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }
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
      _broadcastLocation((LocationData.fromMap(
          {"latitude": location.latitude, "longitude": location.longitude})));
    });
  }

  void _broadcastLocation(LocationData newLocation) {
    _locationStreamController.add(newLocation);
  }
}
