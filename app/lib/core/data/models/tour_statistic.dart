import 'package:latlong2/latlong.dart';

class TourStatistic {
  String? id;
  LatLng? centerPoint;

  TourStatistic({this.id, this.centerPoint});

  factory TourStatistic.fromJson(Map<String, dynamic> json) {
    return TourStatistic(
      id: json['id'],
      centerPoint: fromPointString(json['centerPoint']),
    );
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
