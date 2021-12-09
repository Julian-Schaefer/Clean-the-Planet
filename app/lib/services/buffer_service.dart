import 'package:clean_the_planet/constants.dart';
import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';

abstract class TourBufferService {
  Future<Polygon> getBuffer(List<LatLng> polyline);
}

class TourBufferServiceLoadException implements Exception {}

class TourBufferServiceImpl extends TourBufferService {
  final Client _client = getInterceptedClient();

  @override
  Future<Polygon> getBuffer(List<LatLng> polyline) async {
    var relativeUrl = "/buffer";
    final response = await _client.post(
        Uri.parse(getAPIBaseUrl() + relativeUrl),
        body: jsonEncode({"polyline": Tour.getPolylineString(polyline)}));

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      return Tour.fromPolygonString(parsedJson['polygon']);
    } else {
      throw TourBufferServiceLoadException();
    }
  }
}
