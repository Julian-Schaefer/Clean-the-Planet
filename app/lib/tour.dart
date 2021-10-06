import 'package:latlong2/latlong.dart';

class Tour {
  String? id;
  final List<LatLng> polyline;
  List<LatLng>? polygon;
  List<String>? resultPictureKeys;
  List<String>? resultPictures;

  Tour(
      {this.id,
      required this.polyline,
      this.polygon,
      this.resultPictureKeys,
      this.resultPictures});

  factory Tour.fromJson(Map<String, dynamic> json) {
    List<String>? resultPictureKeys;
    if (json['picture_keys'] != null) {
      resultPictureKeys = List<String>.from(json['picture_keys']);
    }

    List<String>? resultPictures;
    if (json['result_pictures'] != null) {
      resultPictures = List<String>.from(json['result_pictures']);
    }

    return Tour(
      id: json['id'],
      polyline: fromPolylineString(json['polyline']),
      polygon: fromPolygonString(json['polygon']),
      resultPictureKeys: resultPictureKeys,
      resultPictures: resultPictures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline': getPolylineString(polyline),
      'picture_keys': resultPictureKeys
    };
  }

  static String getPolygonString(List<LatLng> polygon) {
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

  static String getPolylineString(List<LatLng> polyline) {
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
