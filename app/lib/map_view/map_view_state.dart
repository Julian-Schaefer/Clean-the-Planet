import 'package:equatable/equatable.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

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
  const InitialMapViewState(LocationData? currentLocation)
      : super(
            currentLocation: currentLocation,
            polylineCoordinates: const [],
            collectionStarted: false);
}
