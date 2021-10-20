import 'package:latlong2/latlong.dart';

class TourPicture {
  String? id;
  final LatLng location;
  final String? imageKey;
  final String? imageUrl;
  final String? comment;

  TourPicture(
      {this.id,
      required this.location,
      this.imageKey,
      this.imageUrl,
      this.comment});

  factory TourPicture.fromJson(Map<String, dynamic> json) {
    return TourPicture(
        id: json['id'],
        location: fromPointString(json['location']),
        imageUrl: json['imageUrl'],
        comment: json['comment']);
  }

  Map<String, dynamic> toJson() {
    return {
      'imageKey': imageKey,
      'location': getPointString(location),
      'comment': comment
    };
  }

  static String getPointString(LatLng location) {
    String pointString = "POINT(" +
        location.latitude.toString() +
        " " +
        location.longitude.toString() +
        ')';

    return pointString;
  }

  static LatLng fromPointString(String pointString) {
    pointString = pointString.substring("POINT(".length);
    pointString = pointString.substring(0, pointString.length - 1);

    List<String> coords = pointString.split(" ");
    double latitude = double.parse(coords[0]);
    double longitude = double.parse(coords[1]);
    return LatLng(latitude, longitude);
  }
}
