import 'package:latlong2/latlong.dart';

class Tour {
  String? id;
  final List<LatLng> polyline;
  List<LatLng>? polygon;

  Tour({this.id, required this.polyline, this.polygon});

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      polyline: fromPolylineString(json['polyline']),
      polygon: fromPolygonString(json['polygon']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'polyline': getPolylineString()};
  }

  String? getPolygonString() {
    if (polygon == null) {
      return null;
    }

    String polygonString = "POLYGON((";
    LatLng firstCoord = polygon!.first;
    for (LatLng coord in polygon!) {
      polygonString +=
          coord.latitude.toString() + " " + coord.longitude.toString() + ",";
    }

    polygonString += firstCoord.latitude.toString() +
        " " +
        firstCoord.longitude.toString() +
        "))";

    return polygonString;
  }

  static List<LatLng> fromPolygonString(String polygonString) {
    List<LatLng> polygon = [];

    polygonString = polygonString.substring("POLYGON((".length);
    polygonString = polygonString.substring(0, polygonString.length - 2);

    for (var coord in polygonString.split(",")) {
      List<String> coords = coord.split(" ");
      double latitude = double.parse(coords[0]);
      double longitude = double.parse(coords[1]);
      polygon.add(LatLng(latitude, longitude));
    }

    return polygon;
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

  static List<LatLng> fromPolylineString(String polylineString) {
    List<LatLng> polyline = [];

    polylineString = polylineString.substring("LINESTRING(".length);
    polylineString = polylineString.substring(0, polylineString.length - 1);

    for (var coord in polylineString.split(",")) {
      List<String> coords = coord.split(" ");
      double latitude = double.parse(coords[0]);
      double longitude = double.parse(coords[1]);
      polyline.add(LatLng(latitude, longitude));
    }

    return polyline;
  }
}
