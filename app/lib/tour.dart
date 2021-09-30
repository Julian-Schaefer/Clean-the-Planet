import 'package:latlong2/latlong.dart';

class Tour {
  String? id;
  final List<LatLng> polyline;
  final List<LatLng> polygon;

  Tour({this.id, required this.polyline, required this.polygon});

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      polyline: json['polyline'],
      polygon: json['polygon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline': getPolylineString(),
      'polygon': getPolygonString(),
    };
  }

  String getPolygonString() {
    String polygonString = "POLYGON((";
    LatLng firstCoord = polygon.first;
    for (LatLng coord in polygon) {
      polygonString +=
          coord.latitude.toString() + " " + coord.longitude.toString() + ",";
    }

    polygonString += firstCoord.latitude.toString() +
        " " +
        firstCoord.longitude.toString() +
        "))";

    return polygonString;
  }

  String getPolylineString() {
    String polylineString = "LINESTRING(";
    for (LatLng coord in polyline) {
      polylineString +=
          coord.latitude.toString() + " " + coord.longitude.toString() + ",";
    }

    polylineString = polylineString.substring(0, polylineString.length - 1);

    return polylineString + ")";
  }
}
