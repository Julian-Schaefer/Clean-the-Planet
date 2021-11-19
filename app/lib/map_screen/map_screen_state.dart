import 'package:equatable/equatable.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

abstract class MapScreenBlocState extends Equatable {
  final LocationData? currentLocation;
  final List<LatLng> polylineCoordinates;
  final bool collectionStarted;

  const MapScreenBlocState(
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

class InitialMapScreenBlocState extends MapScreenBlocState {
  const InitialMapScreenBlocState(LocationData? currentLocation)
      : super(
            currentLocation: currentLocation,
            polylineCoordinates: const [],
            collectionStarted: false);
}

class UpdatedMapScreenBlocState extends MapScreenBlocState {
  const UpdatedMapScreenBlocState(LocationData? currentLocation,
      List<LatLng> polylineCoordinates, bool collectionStarted)
      : super(
            currentLocation: currentLocation,
            polylineCoordinates: polylineCoordinates,
            collectionStarted: collectionStarted);
}
