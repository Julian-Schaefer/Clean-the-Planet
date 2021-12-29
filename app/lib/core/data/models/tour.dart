import 'package:clean_the_planet/core/data/models/tour_picture.dart';
import 'package:clean_the_planet/core/utils/geo_format_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:clean_the_planet/core/data/extensions/extensions.dart';

class Tour {
  String? id;
  final List<LatLng> polyline;
  final Duration duration;
  final double amount;
  LatLng? centerPoint;
  Polygon? polygon;
  DateTime? dateTime;
  List<String>? resultPictureKeys;
  List<TourPicture>? tourPictures;

  Tour(
      {this.id,
      required this.polyline,
      required this.duration,
      required this.amount,
      this.centerPoint,
      this.polygon,
      this.dateTime,
      this.resultPictureKeys,
      this.tourPictures});

  factory Tour.fromJson(Map<String, dynamic> json) {
    List<String>? resultPictureKeys;
    if (json['resultPictureKeys'] != null) {
      resultPictureKeys = List<String>.from(json['resultPictureKeys']);
    }

    List<TourPicture>? tourPictures;
    if (json['tourPictures'] != null) {
      tourPictures = json['tourPictures']
          .map<TourPicture>((json) => TourPicture.fromJson(json))
          .toList();
    }

    return Tour(
      id: json['id'],
      polyline: GeoFormatter.fromPolylineString(json['polyline']),
      centerPoint: GeoFormatter.fromPointString(json['centerPoint']),
      polygon: GeoFormatter.fromPolygonString(json['polygon']),
      duration: DurationFormatter.parseDuration(json['duration']),
      amount: json['amount'],
      dateTime: DateTime.parse(json['datetime']),
      resultPictureKeys: resultPictureKeys,
      tourPictures: tourPictures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline': GeoFormatter.toPolylineGeoJSON(polyline),
      'duration': duration.toString(),
      'amount': amount,
      'resultPictureKeys': resultPictureKeys,
      "tourPictures": tourPictures
    };
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
