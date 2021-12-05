import 'dart:collection';

import 'package:location/location.dart';
import 'dart:math' as math;

class GeoDataHelper {
  static const int _radiusKM = 6367; // earth's radius km's

  static double getMean(List<double> data) {
    double sum = 0.0;
    for (double a in data) {
      sum += a;
    }

    return sum / data.length;
  }

  static double getVariance(List<double> data) {
    final double mean = getMean(data);
    double temp = 0;
    for (double a in data) {
      temp += (mean - a) * (mean - a);
    }

    return temp / data.length;
  }

  static double getStdDev(List<double> data) {
    return math.sqrt(getVariance(data));
  }

  /// Calculate the average geometric center of a Queue that contains cartesian coordinates
  /// Reference: http://stackoverflow.com/questions/6671183/calculate-the-center-point-of-multiple-latitude-longitude-coordinate-pairs
  /// Reference: http://stackoverflow.com/questions/1185408/converting-from-longitude-latitude-to-cartesian-coordinates
  /// Reference: http://en.wikipedia.org/wiki/Spherical_coordinate_system
  /// @param queue The location buffer queue
  /// @return Returns a Coordinate object
  static LocationData getGeographicCenter(Queue<LocationData> locationQueue) {
    double x = 0;
    double y = 0;
    double z = 0;
    double accuracy = 0;

    for (LocationData coordinate in locationQueue) {
      if (coordinate.accuracy != null &&
          coordinate.latitude != null &&
          coordinate.longitude != null) {
        accuracy += coordinate.accuracy ?? 0;

        // Convert latitude and longitude to radians
        final double latRad = math.pi * coordinate.latitude! / 180;
        final double lonRad = math.pi * coordinate.longitude! / 180;

        // Convert to cartesian coords
        x += _radiusKM * math.cos(latRad) * math.cos(lonRad);
        y += _radiusKM * math.cos(latRad) * math.sin(lonRad);
        z += _radiusKM * math.sin(latRad);
      }
    }

    // Get our averages
    double xAvg = x / locationQueue.length;
    double yAvg = y / locationQueue.length;
    double zAvg = z / locationQueue.length;
    double accuracyAvg = accuracy / locationQueue.length;

    // Convert cartesian back to radians
    double sphericalLatRads = math.asin(zAvg / _radiusKM);
    double sphericalLonRads = math.atan2(yAvg, xAvg);

    double latitude = sphericalLatRads * (180 / math.pi);
    double longitude = sphericalLonRads * (180 / math.pi);
    double centerPointAccuracy = accuracyAvg;

    LocationData centerPoint = LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
      "accuracy": centerPointAccuracy
    });

    return centerPoint;
  }
}
