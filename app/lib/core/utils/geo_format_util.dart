import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

class GeoFormatter {
  static Map<String, dynamic> toPointGeoJSON(LatLng point) {
    return GeoJSONPoint(getCoordFromLatLng(point)).toMap();
  }

  static Map<String, dynamic>? toPolylineGeoJSON(List<LatLng> polyline) {
    if (polyline.isEmpty) {
      return null;
    }

    List<List<double>> coords = [];
    for (LatLng latLng in polyline) {
      coords.add(getCoordFromLatLng(latLng));
    }

    return GeoJSONLineString(coords).toMap();
  }

  static LatLng fromPointString(Map<String, dynamic> pointMap) {
    final point = GeoJSONPoint.fromMap(pointMap);
    return getLatLngFromCoord(point.coordinates);
  }

  static List<LatLng> fromPolylineString(Map<String, dynamic> polylineMap) {
    final lineString = GeoJSONLineString.fromMap(polylineMap);

    List<LatLng> polyline = [];

    for (List<double> coord in lineString.coordinates) {
      polyline.add(getLatLngFromCoord(coord));
    }

    return polyline;
  }

  static Polygon fromPolygonString(Map<String, dynamic> polygonMap) {
    final polygon = GeoJSONPolygon.fromMap(polygonMap);

    List<LatLng> points = [];
    List<List<LatLng>>? holePointsList;

    for (int i = 0; i < polygon.coordinates.length; i++) {
      List<LatLng> coords = [];
      for (List<double> coord in polygon.coordinates[i]) {
        coords.add(getLatLngFromCoord(coord));
      }

      if (i == 0) {
        points = coords;
      } else {
        holePointsList ??= [];
        holePointsList.add(coords);
      }
    }

    return Polygon(
        points: points,
        holePointsList: holePointsList,
        color: Colors.red.withOpacity(0.6));
  }

  static LatLng getLatLngFromCoord(List<double> coord) {
    double latitude = coord[1];
    double longitude = coord[0];
    return LatLng(latitude, longitude);
  }

  static List<double> getCoordFromLatLng(LatLng latLng) {
    return [latLng.longitude, latLng.latitude];
  }
}
