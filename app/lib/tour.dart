import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class Tour {
  String? id;
  final List<LatLng> polyline;
  Polygon? polygon;
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

  // static String getPolygonString(List<LatLng> polygon) {
  //   String polygonString = "POLYGON((";
  //   LatLng firstCoord = polygon.first;
  //   for (LatLng coord in polygon) {
  //     polygonString +=
  //         coord.latitude.toString() + " " + coord.longitude.toString() + ",";
  //   }

  //   polygonString += firstCoord.latitude.toString() +
  //       " " +
  //       firstCoord.longitude.toString() +
  //       "))";

  //   return polygonString;
  // }

  static Polygon fromPolygonString(String polygonString) {
    List<LatLng> points = [];

    List<String> polygonParts = polygonString.split("),(");
    String pointsString = polygonParts[0];
    pointsString = pointsString.substring("POLYGON((".length);
    pointsString = pointsString.substring(0, pointsString.length - 2);

    for (var coord in pointsString.split(",")) {
      List<String> coords = coord.split(" ");
      double latitude = double.parse(coords[0]);
      double longitude = double.parse(coords[1]);
      points.add(LatLng(latitude, longitude));
    }

    List<List<LatLng>>? holePointsList;
    if (polygonParts.length > 1) {
      holePointsList = [];
    }

    for (int i = 1; i < polygonParts.length; i++) {
      String holeString = polygonParts[i];
      if (holeString.contains("))")) {
        holeString = holeString.substring(0, holeString.length - 2);
      }

      List<LatLng> holes = [];
      for (var coord in holeString.split(",")) {
        List<String> coords = coord.split(" ");
        double latitude = double.parse(coords[0]);
        double longitude = double.parse(coords[1]);
        holes.add(LatLng(latitude, longitude));
      }

      holePointsList!.add(holes);
    }

    return Polygon(
        points: points,
        holePointsList: holePointsList,
        color: Colors.red.withOpacity(0.6));
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
