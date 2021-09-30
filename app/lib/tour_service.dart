import 'dart:io';

import 'package:clean_the_planet/json_interceptor.dart';
import 'package:clean_the_planet/tour.dart';
//import 'package:blogify/JsonInterceptor.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http_interceptor/http_interceptor.dart';

class TourService {
  static final Client _client = InterceptedClient.build(interceptors: [
    JsonInterceptor(),
  ]);

  static String _getBaseUrl() {
    if (kReleaseMode) {
      return "https://clean-the-planet.herokuapp.com/";
    } else {
      return "http://localhost:5000";
    }
  }

  // static Future<List<BlogPost>> getBlogPosts(int page) async {
  //   var relativeUrl = "/blog-selection";
  //   relativeUrl += "?page=" + page.toString();

  //   try {
  //     final response =
  //         await _client.get(Uri.parse(_getBaseUrl() + relativeUrl));

  //     if (response.statusCode == 200) {
  //       final parsedJson =
  //           jsonDecode(response.body).cast<Map<String, dynamic>>();

  //       return parsedJson
  //           .map<BlogPost>((json) => BlogPost.fromJson(json))
  //           .toList();
  //     } else {
  //       // If the server did not return a 200 OK response,
  //       // then throw an exception.
  //       throw Exception('Failed to load Blog Posts.');
  //     }
  //   } on SocketException {
  //     return Future.error('No Internet connection 😑');
  //   } on FormatException {
  //     return Future.error('Bad response format 👎');
  //   } on Exception {
  //     return Future.error('Unexpected error 😢');
  //   }
  // }

  static Future<void> addTour(Tour tour) async {
    var relativeUrl = "/tour";
    try {
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
}
