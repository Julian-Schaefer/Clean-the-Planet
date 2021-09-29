import 'package:latlong2/latlong.dart';

class Tour {
  String? id;
  final List<LatLng> polygon;

  Tour({this.id, required this.polygon});

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      polygon: json['polygon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}
