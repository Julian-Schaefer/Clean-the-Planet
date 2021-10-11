import 'dart:io';

import 'package:clean_the_planet/json_interceptor.dart';
import 'package:clean_the_planet/tour.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'package:http_interceptor/http_interceptor.dart';

class TourService {
  static final Client _client = InterceptedClient.build(interceptors: [
    JsonInterceptor(),
  ]);

  static String _getBaseUrl() {
    if (kReleaseMode) {
      return "https://clean-the-planet.herokuapp.com";
    } else {
      return "https://clean-the-planet.loca.lt";
    }
  }

  static Future<void> addTour(Tour tour) async {
    var relativeUrl = "/tour";
    try {
      if (tour.resultPictureKeys != null &&
          tour.resultPictureKeys!.isNotEmpty) {
        var pictureKeys = await _uploadPictures(tour.resultPictureKeys!);
        tour.resultPictureKeys = pictureKeys;
      }

      final response = await _client
          .post(Uri.parse(_getBaseUrl() + relativeUrl), body: jsonEncode(tour));

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to add Tour.');
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException {
      return Future.error('Bad response format 👎');
    } catch (e) {
      return Future.error('Unexpected error 😢');
    }
  }

  static Future<List<Tour>> getTours() async {
    var relativeUrl = "/tour";
    try {
      final response =
          await _client.get(Uri.parse(_getBaseUrl() + relativeUrl));

      if (response.statusCode == 200) {
        final parsedJson =
            jsonDecode(response.body).cast<Map<String, dynamic>>();

        return parsedJson.map<Tour>((json) => Tour.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get Tour.');
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException {
      return Future.error('Bad response format 👎');
    } catch (e) {
      return Future.error('Unexpected error 😢');
    }
  }

  static Future<Polygon> getBuffer(List<LatLng> polyline) async {
    var relativeUrl = "/buffer";
    try {
      final response = await _client.post(
          Uri.parse(_getBaseUrl() + relativeUrl),
          body: jsonEncode({"polyline": Tour.getPolylineString(polyline)}));

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        return Tour.fromPolygonString(parsedJson['polygon']);
      } else {
        throw Exception('Failed to get Buffer.');
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException {
      return Future.error('Bad response format 👎');
    } catch (e) {
      return Future.error('Unexpected error 😢');
    }
  }

  static Future<List<String>> _uploadPictures(List<String> paths) async {
    MultipartRequest request =
        MultipartRequest('POST', Uri.parse(_getBaseUrl() + '/pictures'));
    for (String path in paths) {
      request.files.add(await MultipartFile.fromPath('files', path));
    }

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBytes = await response.stream.toBytes();
      var responseBody = utf8.decode(responseBytes);
      final parsedJson = jsonDecode(responseBody);
      List<String> pictureKeys = List<String>.from(parsedJson["picture_keys"]);
      return pictureKeys;
    } else {
      throw Exception('Failed to upload Pictures.');
    }
  }
}
