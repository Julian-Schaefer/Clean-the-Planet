import 'package:clean_the_planet/core/data/models/tour_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class Tour {
  String? id;
  final List<LatLng> polyline;
  final Duration duration;
  final double amount;
  Polygon? polygon;
  DateTime? dateTime;
  List<String>? resultPictureKeys;
  List<TourPicture>? tourPictures;

  Tour(
      {this.id,
      required this.polyline,
      required this.duration,
      required this.amount,
      this.polygon,
      this.dateTime,
      this.resultPictureKeys,
      this.tourPictures});

  factory Tour.fromJson(Map<String, dynamic> json) {
    List<String>? resultPictureKeys;
    if (json['resultPictureKeys'] != null) {
      resultPictureKeys = List<String>.from(json['resultPictureKeys']);
    }

    return Tour(
      id: json['id'],
      polyline: fromPolylineString(json['polyline']),
      polygon: fromPolygonString(json['polygon']),
      duration: parseDuration(json['duration']),
      amount: json['amount'],
      dateTime: DateTime.parse(json['datetime']),
      resultPictureKeys: resultPictureKeys,
      tourPictures: json['tourPictures']
          .map<TourPicture>((json) => TourPicture.fromJson(json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline': getPolylineString(polyline),
      'duration': duration.toString(),
      'amount': amount,
      'resultPictureKeys': resultPictureKeys,
      "tourPictures": tourPictures
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

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  String getLocalAmountString(Locale locale) {
    return NumberFormat.decimalPattern(locale.languageCode).format(amount);
  }

  static double toLocalDecimalAmount(String amount, Locale locale) {
    return NumberFormat.decimalPattern(locale.languageCode)
        .parse(amount)
        .toDouble();
  }
}
