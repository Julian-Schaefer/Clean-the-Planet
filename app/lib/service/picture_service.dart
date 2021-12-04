import 'dart:convert';
import 'dart:io';

import 'package:clean_the_planet/constants.dart';
import 'package:clean_the_planet/core/network/json_interceptor.dart';
import 'package:clean_the_planet/core/data/models/tour_picture.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

abstract class PictureService {
  Future<List<String>> uploadResultPictures(List<String> paths);
  Future<List<TourPicture>> uploadTourPictures(List<TourPicture> tourPictures);
}

class PictureServiceImpl extends PictureService {
  @override
  Future<List<String>> uploadResultPictures(List<String> paths) async {
    MultipartRequest request = MultipartRequest(
        'POST', Uri.parse(getAPIBaseUrl() + '/result-pictures'));
    for (String path in paths) {
      request.files.add(await MultipartFile.fromPath('files', path));
    }

    Map<String, String> headers = await JsonInterceptor.getHeaders();
    request.headers.addAll(headers);

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

  @override
  Future<List<TourPicture>> uploadTourPictures(
      List<TourPicture> tourPictures) async {
    MultipartRequest request =
        MultipartRequest('POST', Uri.parse(getAPIBaseUrl() + '/tour-pictures'));
    for (TourPicture picture in tourPictures) {
      File imageFile = File(picture.imageKey!);
      String fileName = basename(imageFile.path);
      request.fields[fileName] = jsonEncode(picture);
      request.files.add(await MultipartFile.fromPath('files', picture.imageKey!,
          filename: fileName));
    }
    Map<String, String> headers = await JsonInterceptor.getHeaders();
    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBytes = await response.stream.toBytes();
      var responseBody = utf8.decode(responseBytes);
      final parsedJson = jsonDecode(responseBody);
      return parsedJson
          .map<TourPicture>((json) => TourPicture.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to upload Pictures.');
    }
  }
}
