import 'dart:async';
import 'dart:io';

import 'package:background_location/background_location.dart' as geo;
import 'package:clean_the_planet/map_screen/map_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'package:clean_the_planet/permission_util.dart';

abstract class MapScreenEvent {}

class RefreshCurrentLocation extends MapScreenEvent {}

class StartLocationListening extends MapScreenEvent {}

class UpdateRoute extends MapScreenEvent {
  final MapScreenBlocState newState;

  UpdateRoute(this.newState);
}

class StartCollecting extends MapScreenEvent {}

class FinishCollecting extends MapScreenEvent {}

class MapScreenBloc extends Bloc<MapScreenEvent, MapScreenBlocState> {
  static const int interval = 1500;
  static const double distanceFilter = 5.0;

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  MapScreenBloc() : super(const InitialMapScreenBlocState(null)) {
    on<RefreshCurrentLocation>((_, Emitter<MapScreenBlocState> emit) async {
      await _refreshCurrentLocation();
    });

    on<StartLocationListening>((_, Emitter<MapScreenBlocState> emit) async {
      emit(InitialMapScreenBlocState(state.currentLocation));
      await _getInitialLocation();
    });

    on<UpdateRoute>(
        (UpdateRoute event, Emitter<MapScreenBlocState> emit) async {
      emit(event.newState);
    });

    on<StartCollecting>((_, Emitter<MapScreenBlocState> emit) async {
      MapScreenBlocState newState = await _startCollecting();
      emit(newState);
    });

    on<FinishCollecting>((_, Emitter<MapScreenBlocState> emit) async {
      MapScreenBlocState newState = await _finishCollecting();
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

  Future<MapScreenBlocState> _startCollecting() async {
    if (!state.locationReady()) {
      return state;
    }

    if (Platform.isIOS) {
      _location.enableBackgroundMode(enable: true);
    } else if (Platform.isAndroid) {
      await _locationSubscription!.cancel();
      _startAndroidBackgroundLocationService();
    }

    List<LatLng> newPolyCoordinates = [...state.polylineCoordinates];
    newPolyCoordinates.add(LatLng(
        state.currentLocation!.latitude!, state.currentLocation!.longitude!));

    return UpdatedMapScreenBlocState(
        state.currentLocation, newPolyCoordinates, true);
  }

  Future<MapScreenBlocState> _finishCollecting() async {
    if (!state.locationReady()) {
      return state;
    }

    if (Platform.isIOS) {
      await _locationSubscription!.cancel();
      _location.enableBackgroundMode(enable: false);
    } else if (Platform.isAndroid) {
      geo.BackgroundLocation.stopLocationService();
    }

    return UpdatedMapScreenBlocState(
        state.currentLocation, state.polylineCoordinates, false);
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

    var newState = UpdatedMapScreenBlocState(
        newLocation, newPolyCoordinates, state.collectionStarted);

    add(UpdateRoute(newState));
  }
}
