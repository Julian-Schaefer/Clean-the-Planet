import 'dart:async';

import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/screens/map_screen/map_screen_state.dart';
import 'package:clean_the_planet/services/location_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

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
  StreamSubscription<LocationData>? _locationSubscription;

  final LocationService _locationService = getIt<LocationService>();

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
    _locationSubscription?.cancel();
    _locationService.close();
    return super.close();
  }

  Future<void> _getInitialLocation() async {
    _startLocationListening();
    _locationService.getInitialLocation();
  }

  void _startLocationListening() {
    _locationSubscription ??=
        _locationService.onLocationChanged.listen((newLocation) {
      _updateRoute(newLocation);
    });
  }

  Future<void> _refreshCurrentLocation() async {
    LocationData refreshedLocation =
        await _locationService.getCurrentLocation();
    _updateRoute(refreshedLocation);
  }

  Future<MapScreenBlocState> _startCollecting() async {
    if (!state.locationReady()) {
      return state;
    }

    await _locationService.startCollecting();

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

    await _locationService.finishCollecting();

    return UpdatedMapScreenBlocState(
        state.currentLocation, state.polylineCoordinates, false);
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
