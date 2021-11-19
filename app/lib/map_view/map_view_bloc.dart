import 'dart:async';
import 'dart:io';

import 'package:background_location/background_location.dart' as geo;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'package:clean_the_planet/permission_util.dart';

abstract class MapViewEvent {}

class RefreshCurrentLocation extends MapViewEvent {}

class StartLocationListening extends MapViewEvent {}

class UpdateRoute extends MapViewEvent {
  final MapViewState newState;

  UpdateRoute(this.newState);
}

class StartCollecting extends MapViewEvent {}

class FinishCollecting extends MapViewEvent {}

class Decrement extends MapViewEvent {}

abstract class MapViewState extends Equatable {
  final LocationData? currentLocation;
  final List<LatLng> polylineCoordinates;
  final bool collectionStarted;

  const MapViewState(
      {required this.currentLocation,
      required this.polylineCoordinates,
      required this.collectionStarted});

  bool locationReady() {
    return !(currentLocation == null ||
        currentLocation!.latitude == null ||
        currentLocation!.longitude == null);
  }

  @override
  List<Object?> get props =>
      [currentLocation, polylineCoordinates, collectionStarted];
}

class InitialMapViewState extends MapViewState {
  const InitialMapViewState()
      : super(
            currentLocation: null,
            polylineCoordinates: const [],
            collectionStarted: false);
}

class UpdatedMapViewState extends MapViewState {
  const UpdatedMapViewState(LocationData? currentLocation,
      List<LatLng> polylineCoordinates, bool collectionStarted)
      : super(
            currentLocation: currentLocation,
            polylineCoordinates: polylineCoordinates,
            collectionStarted: collectionStarted);
}

class MapViewBloc extends Bloc<MapViewEvent, MapViewState> {
  static const int interval = 1500;
  static const double distanceFilter = 5.0;

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  MapViewBloc() : super(const InitialMapViewState()) {
    on<RefreshCurrentLocation>((_, Emitter<MapViewState> emit) async {
      await _refreshCurrentLocation();
    });

    on<StartLocationListening>((_, Emitter<MapViewState> emit) async {
      await _getInitialLocation();
    });

    on<UpdateRoute>((UpdateRoute event, Emitter<MapViewState> emit) async {
      emit(event.newState);
    });

    on<StartCollecting>((_, Emitter<MapViewState> emit) async {
      MapViewState newState = await _startCollecting();
      emit(newState);
    });

    on<FinishCollecting>((_, Emitter<MapViewState> emit) async {
      MapViewState newState = await _finishCollecting();
      emit(newState);
    });
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }
    return super.close();
  }

  Future<void> _getInitialLocation() async {
    //TODO: Remove once fixed
    await Future<void>.delayed(const Duration(seconds: 2));

    bool permissionsGranted =
        await PermissionUtil.askForLocationPermission(_location);

    if (permissionsGranted) {
      await _location.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: interval,
          distanceFilter: distanceFilter);

      _refreshCurrentLocation();
      _listenForLocationUpdates();
    }
  }

  Future<void> _refreshCurrentLocation() async {
    LocationData refreshedLocation = await _location.getLocation();
    _updateRoute(refreshedLocation);
  }

  void _listenForLocationUpdates() {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData newLocation) {
      _updateRoute(newLocation);
    });
  }

  Future<MapViewState> _startCollecting() async {
    if (!state.locationReady()) {
      return state;
    }

    // if (!(await PermissionUtil.askForBatteryOptimizationPermission(context))) {
    //   return;
    // }

    if (Platform.isIOS) {
      _location.enableBackgroundMode(enable: true);
    } else if (Platform.isAndroid) {
      await _locationSubscription!.cancel();
      _startAndroidBackgroundLocationService();
    }

    //setState(() {
    //  takePictureAvailable = true;
    //  _timerWidgetController.startTimer!.call();

    List<LatLng> newPolyCoordinates = [...state.polylineCoordinates];
    newPolyCoordinates.add(LatLng(
        state.currentLocation!.latitude!, state.currentLocation!.longitude!));

    return UpdatedMapViewState(state.currentLocation, newPolyCoordinates, true);
    //});
  }

  Future<MapViewState> _finishCollecting() async {
    if (!state.locationReady()) {
      return state;
    }

    if (Platform.isIOS) {
      await _locationSubscription!.cancel();
      _location.enableBackgroundMode(enable: false);
    } else if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }

    return UpdatedMapViewState(
        state.currentLocation, state.polylineCoordinates, false);

    //setState(() {
    //_timerWidgetController.stopTimer!.call();
    //});

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => SummaryScreen(
    //             polylineCoordinates: _polylineCoordinates,
    //             finalLocation: _currentLocation!,
    //             duration: _timerWidgetController.duration,
    //             tourPictures: _tourPictures,
    //           )),
    // ).then((_) => setState(() {
    //       //_tourPictures.clear();
    //       state.polylineCoordinates.clear();
    //       //_timerWidgetController.resetTimer!.call();
    //       listenForLocationUpdates();
    //     }));
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
      _updateRoute((LocationData.fromMap(
          {"latitude": location.latitude, "longitude": location.longitude})));
    });
  }

  void _updateRoute(LocationData newLocation) async {
    if (newLocation.latitude == null || newLocation.longitude == null) {
      return;
    }

    var newLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);

    List<LatLng> newPolyCoordinates = [...state.polylineCoordinates];

    if (state.collectionStarted) {
      newPolyCoordinates.add(newLatLng);
    }

    var newState = UpdatedMapViewState(
        newLocation, newPolyCoordinates, state.collectionStarted);

    add(UpdateRoute(newState));
  }
}
