import 'package:flutter_map/flutter_map.dart';

extension LatLngToLineString on LatLngBounds {
  String toLineString() {
    String polylineString = "LINESTRING(";
    for (var coord in [northWest, southEast]) {
      polylineString +=
          coord.latitude.toString() + " " + coord.longitude.toString() + ",";
    }

    polylineString = polylineString.substring(0, polylineString.length - 1);

    return polylineString + ")";
  }
}

extension DurationFormatter on Duration {
  String getDurationString() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(inHours);
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    return hours + ":" + minutes + ":" + seconds;
  }
}
