import 'package:clean_the_planet/constants.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/service/picture_service.dart';
import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:http/http.dart';
import 'dart:convert';

abstract class TourService {
  Future<void> addTour(Tour tour);
  Future<List<Tour>> getTours();
  Future<void> deleteTour(Tour tour);
}

class TourServiceImpl extends TourService {
  final Client _client = getInterceptedClient();
  final PictureService pictureService = getIt<PictureService>();

  @override
  Future<void> addTour(Tour tour) async {
    var relativeUrl = "/tour";
    try {
      if (tour.resultPictureKeys != null &&
          tour.resultPictureKeys!.isNotEmpty) {
        var pictureKeys =
            await pictureService.uploadResultPictures(tour.resultPictureKeys!);
        tour.resultPictureKeys = pictureKeys;
      }

      if (tour.tourPictures != null && tour.tourPictures!.isNotEmpty) {
        var tourPictures =
            await pictureService.uploadTourPictures(tour.tourPictures!);
        tour.tourPictures = tourPictures;
      }

      final response = await _client.post(
          Uri.parse(getAPIBaseUrl() + relativeUrl),
          body: jsonEncode(tour));

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to add Tour.');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<Tour>> getTours() async {
    var relativeUrl = "/tour";
    try {
      final response =
          await _client.get(Uri.parse(getAPIBaseUrl() + relativeUrl));

      if (response.statusCode == 200) {
        final parsedJson =
            jsonDecode(response.body).cast<Map<String, dynamic>>();

        return parsedJson.map<Tour>((json) => Tour.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get Tour.');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteTour(Tour tour) async {
    var relativeUrl = "/tour";
    final response = await _client
        .delete(Uri.parse(getAPIBaseUrl() + relativeUrl + "?id=" + tour.id!));

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to get Tour.');
    }
  }
}
