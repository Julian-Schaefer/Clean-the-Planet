import 'package:clean_the_planet/core/utils/geo_format_util.dart';
import 'package:latlong2/latlong.dart';

class TourPicture {
  String? id;
  final LatLng location;
  final String? pictureKey;
  final String? imagePath;
  final String? comment;

  TourPicture(
      {this.id,
      required this.location,
      this.pictureKey,
      this.imagePath,
      this.comment});

  factory TourPicture.fromJson(Map<String, dynamic> json) {
    return TourPicture(
        id: json['id'],
        location: GeoFormatter.fromPointString(json['location']),
        pictureKey: json['pictureKey'],
        comment: json['comment']);
  }

  Map<String, dynamic> toJson() {
    return {
      'pictureKey': pictureKey,
      'location': GeoFormatter.toPointGeoJSON(location),
      'comment': comment
    };
  }
}
