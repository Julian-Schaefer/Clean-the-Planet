import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:background_location/background_location.dart' as geo;
import 'package:clean_the_planet/core/utils/geo_data_util.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/services/permission_service.dart';
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class LocationService {
  final AppLocalizations? appLocalizations;
  LocationService({this.appLocalizations});

  late Stream<LocationData> onLocationChanged;

  Future<void> close();
  Future<void> getInitialLocation();
  Future<LocationData> getCurrentLocation();
  Future<void> startCollecting();
  Future<void> finishCollecting();
}

class LocationServiceImpl extends LocationService {
  static const int queueSize = 3;
  static const int interval = 500;
  static const double distanceFilter = 0.0;
  static const double accuracyRequirement = 20; // in meters

  final Queue<LocationData> locationQueue = Queue();

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  final PermissionService permissionService = getIt<PermissionService>();

  final StreamController<LocationData> _locationStreamController =
      StreamController<LocationData>();

  LocationServiceImpl(AppLocalizations? appLocalizations)
      : super(appLocalizations: appLocalizations) {
    onLocationChanged = _locationStreamController.stream;
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }
  }

  @override
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
      _broadcastLocation(initialLocation, useQueue: false);
      listenForLocationUpdates();
    }
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    LocationData refreshedLocation = await _location.getLocation();
    while (refreshedLocation.accuracy == null ||
        refreshedLocation.accuracy! > accuracyRequirement) {
      await Future.delayed(const Duration(seconds: 1));
      refreshedLocation = await _location.getLocation();
    }

    return refreshedLocation;
  }

  void listenForLocationUpdates() {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData newLocation) {
      _broadcastLocation(newLocation);
    });
  }

  @override
  Future<void> startCollecting() async {
    if (Platform.isIOS) {
      _location.enableBackgroundMode(enable: true);
    } else if (Platform.isAndroid) {
      await _locationSubscription!.cancel();
      _startAndroidBackgroundLocationService();
    }
  }

  @override
  Future<void> finishCollecting() async {
    if (Platform.isIOS) {
      await _locationSubscription!.cancel();
      _location.enableBackgroundMode(enable: false);
    } else if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }
  }

  void _startAndroidBackgroundLocationService() async {
    String title =
        appLocalizations?.notificationTitle ?? "Clean the Planet: Collecting";
    String description = appLocalizations?.notificationDescription ??
        "We are using your location while you collect.";

    geo.BackgroundLocation.setAndroidNotification(
      title: title,
      message: description,
      icon: "@mipmap/ic_launcher",
    );

    await geo.BackgroundLocation.setAndroidConfiguration(interval);
    geo.BackgroundLocation.startLocationService(distanceFilter: distanceFilter);
    geo.BackgroundLocation.getLocationUpdates((location) {
      _broadcastLocation((LocationData.fromMap({
        "latitude": location.latitude,
        "longitude": location.longitude,
        "accuracy": location.accuracy
      })));
    });
  }

  void _broadcastLocation(LocationData newLocation, {useQueue = true}) {
    if (useQueue) {
      locationQueue.add(newLocation);
      if (locationQueue.length == queueSize) {
        LocationData centerLocation =
            GeoDataHelper.getGeographicCenter(locationQueue);
        _locationStreamController.add(centerLocation);
        locationQueue.clear();
      }
    } else {
      _locationStreamController.add(newLocation);
    }
  }
}
