import 'package:clean_the_planet/constants.dart';
import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:clean_the_planet/core/data/extensions/extensions.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'dart:convert';

abstract class StatisticsService {
  Future<List<Tour>> getTourStatisticsWithBounds(LatLngBounds latLngBounds);
}

class StatisticsServiceImpl extends StatisticsService {
  final Client _client = getInterceptedClient();

  @override
  Future<List<Tour>> getTourStatisticsWithBounds(
      LatLngBounds latLngBounds) async {
    var relativeUrl = "/statistics";
    try {
      final response = await _client.get(Uri.parse(getAPIBaseUrl() +
          relativeUrl +
          "?bounds=" +
          latLngBounds.toLineString()));

      if (response.statusCode == 200) {
        final parsedJson =
            jsonDecode(response.body).cast<Map<String, dynamic>>();

        return parsedJson.map<Tour>((json) => Tour.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get Tour Statistics.');
      }
    } catch (e) {
      return Future.error(e);
    }
  }
}
