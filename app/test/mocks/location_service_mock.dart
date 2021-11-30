import 'package:clean_the_planet/service/location_service.dart';
import 'package:location/location.dart';

class LocationServiceMock extends LocationService {
  static const int interval = 1500;
  static const double distanceFilter = 5.0;

  LocationServiceMock() {
    onLocationChanged = Stream.periodic(const Duration(seconds: 2), (_) {
      return LocationData.fromMap({"latitude": 5.23, "longitude": 6.2});
    });
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> getInitialLocation() async {
    listenForLocationUpdates();
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    LocationData refreshedLocation =
        LocationData.fromMap({"latitude": 5.23, "longitude": 6.2});
    return refreshedLocation;
  }

  void listenForLocationUpdates() {}

  @override
  Future<void> startCollecting() async {}

  @override
  Future<void> finishCollecting() async {}
}
