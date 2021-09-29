import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:latlong2/latlong.dart';

// List<LatLng> pointies = [
//   LatLng(45.878521, 3.694520),
//   LatLng(45.879269, 3.693960),
//   LatLng(45.880539, 3.694340),
//   LatLng(45.882172, 3.694080),
//   LatLng(45.883900, 3.692780),
//   LatLng(45.884430, 3.692930),
//   LatLng(45.885101, 3.692600),
//   LatLng(45.885490, 3.692590),
//   LatLng(45.887169, 3.692070),
//   LatLng(45.887421, 3.691580),
//   LatLng(45.888000, 3.690050),
//   LatLng(45.888889, 3.689280),
//   LatLng(45.889408, 3.688710),
//   LatLng(45.890331, 3.688690),
//   LatLng(45.890461, 3.688480),
//   LatLng(45.890511, 3.687520),
//   LatLng(45.891251, 3.687020),
//   LatLng(45.891769, 3.686900),
//   LatLng(45.894039, 3.687510),
//   LatLng(45.896568, 3.688810),
//   LatLng(45.897430, 3.689040),
//   LatLng(45.898140, 3.688630),
//   LatLng(45.898769, 3.687980),
//   LatLng(45.899719, 3.687290),
//   LatLng(45.900040, 3.687170),
//   LatLng(45.900101, 3.686700),
//   LatLng(45.900570, 3.685970),
//   LatLng(45.901321, 3.685550),
//   LatLng(45.902061, 3.685050),
//   LatLng(45.903030, 3.683950),
//   LatLng(45.903412, 3.683880),
//   LatLng(45.903938, 3.683920),
//   LatLng(45.905102, 3.683280),
//   LatLng(45.906361, 3.682710),
//   LatLng(45.906681, 3.682380),
//   LatLng(45.907082, 3.682250),
//   LatLng(45.907970, 3.682800),
//   LatLng(45.908772, 3.682820),
//   LatLng(45.909149, 3.683270),
//   LatLng(45.909370, 3.684730),
//   LatLng(45.909679, 3.685440),
//   LatLng(45.910191, 3.685902),
//   LatLng(45.910381, 3.686270),
//   LatLng(45.911282, 3.686700),
//   LatLng(45.912209, 3.687900),
//   LatLng(45.912281, 3.688140),
//   LatLng(45.912128, 3.688280),
//   LatLng(45.911942, 3.689290),
//   LatLng(45.911709, 3.690250),
//   LatLng(45.911339, 3.691200),
//   LatLng(45.911491, 3.693050),
//   LatLng(45.912109, 3.695400),
//   LatLng(45.913391, 3.698570),
//   LatLng(45.913940, 3.700200),
//   LatLng(45.914688, 3.701790),
//   LatLng(45.915218, 3.702120),
//   LatLng(45.916248, 3.703170),
//   LatLng(45.916889, 3.703440),
//   LatLng(45.917122, 3.703860),
//   LatLng(45.917210, 3.704280),
//   LatLng(45.917770, 3.704750),
//   LatLng(45.918739, 3.704860),
//   LatLng(45.919571, 3.704730),
//   LatLng(45.919861, 3.704920),
//   LatLng(45.920139, 3.706380),
//   LatLng(45.920460, 3.706880),
//   LatLng(45.920818, 3.708750),
//   LatLng(45.921249, 3.709650),
//   LatLng(45.921680, 3.711240),
//   LatLng(45.921822, 3.712880),
//   LatLng(45.921860, 3.715220),
//   LatLng(45.921951, 3.715510),
//   LatLng(45.922371, 3.715930),
//   LatLng(45.922691, 3.718220),
//   LatLng(45.922958, 3.719330),
//   LatLng(45.923012, 3.720330),
//   LatLng(45.922821, 3.721420),
//   LatLng(45.923988, 3.718530),
//   LatLng(45.924110, 3.717490),
//   LatLng(45.924030, 3.716700),
//   LatLng(45.924389, 3.715310),
//   LatLng(45.924671, 3.714956),
//   LatLng(45.925072, 3.714200),
//   LatLng(45.925621, 3.711630),
//   LatLng(45.926830, 3.709340),
//   LatLng(45.927231, 3.709070),
//   LatLng(45.928013, 3.708873),
//   LatLng(45.929050, 3.708430),
//   LatLng(45.929790, 3.707750),
//   LatLng(45.930168, 3.707290),
//   LatLng(45.930759, 3.707410),
//   LatLng(45.931370, 3.707620),
//   LatLng(45.931900, 3.707470),
//   LatLng(45.932739, 3.706920),
//   LatLng(45.933529, 3.705940),
//   LatLng(45.934410, 3.703300),
//   LatLng(45.934662, 3.701430),
//   LatLng(45.934841, 3.699650),
//   LatLng(45.934700, 3.698620),
//   LatLng(45.934841, 3.697930),
//   LatLng(45.935371, 3.696900),
//   LatLng(45.935741, 3.696590),
//   LatLng(45.936520, 3.695530),
//   LatLng(45.936661, 3.695120),
//   LatLng(45.936729, 3.694160),
//   LatLng(45.936600, 3.693150),
//   LatLng(45.936710, 3.692080),
//   LatLng(45.936699, 3.691320),
//   LatLng(45.936989, 3.690560),
//   LatLng(45.938160, 3.689220),
//   LatLng(45.939362, 3.688750),
//   LatLng(45.940102, 3.688380),
//   LatLng(45.940521, 3.687900),
//   LatLng(45.940731, 3.687590),
//   LatLng(45.940990, 3.686870),
//   LatLng(45.941479, 3.686270),
//   LatLng(45.941959, 3.685800),
//   LatLng(45.942169, 3.685150),
//   LatLng(45.942520, 3.684640),
//   LatLng(45.942829, 3.683400),
//   LatLng(45.943020, 3.682970),
//   LatLng(45.943199, 3.682250),
//   LatLng(45.943600, 3.681720),
//   LatLng(45.944160, 3.681310),
//   LatLng(45.944771, 3.681170),
//   LatLng(45.945690, 3.681750),
//   LatLng(45.946121, 3.681730),
//   LatLng(45.946960, 3.681180),
//   LatLng(45.947201, 3.681140),
//   LatLng(45.948021, 3.681520),
//   LatLng(45.949181, 3.682410),
//   LatLng(45.949741, 3.683030),
//   LatLng(45.949959, 3.683370),
//   LatLng(45.950809, 3.684230),
//   LatLng(45.951229, 3.684470),
//   LatLng(45.952309, 3.685560),
//   LatLng(45.953129, 3.685960),
//   LatLng(45.953758, 3.686160),
//   LatLng(45.954319, 3.685820),
//   LatLng(45.955429, 3.685740),
//   LatLng(45.956108, 3.685940),
//   LatLng(45.956200, 3.686010),
//   LatLng(45.956619, 3.686740),
//   LatLng(45.956860, 3.687270),
//   LatLng(45.956921, 3.687740),
//   LatLng(45.957260, 3.688530),
//   LatLng(45.957809, 3.689250),
//   LatLng(45.958401, 3.689540),
//   LatLng(45.958851, 3.689660),
//   LatLng(45.959599, 3.690140),
//   LatLng(45.959789, 3.690520),
//   LatLng(45.960258, 3.690750),
//   LatLng(45.960571, 3.691020),
//   LatLng(45.961521, 3.692110),
//   LatLng(45.961761, 3.692530)
// ];

List<LatLng> calculatePolygonFromPath(List<LatLng> path) {
  List<LatLng> polyLeft = [];
  List<LatLng> polyRight = [];
  var widthInMeters = 5;

  //Polyline poly = Polyline(points: path, strokeWidth: 2, color: Colors.red);

  void addPoint(num hRight, LatLng currentLatLng,
      {bool left = true, bool right = true}) {
    num hLeft = hRight + 180;
    if (hLeft > 360) hLeft -= 360;
    if (hRight > 360) hRight -= 360;

    mp.LatLng pointRight = mp.SphericalUtil.computeOffset(
        mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
        widthInMeters / 2,
        hRight);
    mp.LatLng pointLeft = mp.SphericalUtil.computeOffset(
        mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
        widthInMeters / 2,
        hLeft);

    if (left) {
      polyLeft.add(LatLng(pointLeft.latitude, pointLeft.longitude));
    }

    if (right) {
      polyRight.add(LatLng(pointRight.latitude, pointRight.longitude));
    }
  }

  for (var i = 0; i < path.length; i++) {
    var currentLatLng = path[i];
    LatLng? lastLatLng;
    LatLng? nextLatLng;
    num headingRight;

    if (i - 1 >= 0) {
      lastLatLng = path[i - 1];
    }

    if (i + 1 < path.length) {
      nextLatLng = path[i + 1];
    }

    if (lastLatLng == null && nextLatLng != null) {
      for (var i = 0; i <= 180; i += 10) {
        var heading = mp.SphericalUtil.computeHeading(
            mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
            mp.LatLng(nextLatLng.latitude, nextLatLng.longitude));
        addPoint(heading, currentLatLng, left: false);
      }
    }

    if (lastLatLng != null) {
      headingRight = mp.SphericalUtil.computeHeading(
              mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
              mp.LatLng(lastLatLng.latitude, lastLatLng.longitude)) -
          90;
      addPoint(headingRight, currentLatLng);
    }

    if (lastLatLng != null && nextLatLng != null) {
      var headingBefore = mp.SphericalUtil.computeHeading(
          mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
          mp.LatLng(lastLatLng.latitude, lastLatLng.longitude));
      var headingAfter = mp.SphericalUtil.computeHeading(
          mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
          mp.LatLng(nextLatLng.latitude, nextLatLng.longitude));
      headingBefore += 360;
      headingBefore = headingBefore % 360;
      headingAfter += 360;
      headingAfter = headingAfter % 360;

      headingRight = (headingBefore + headingAfter) / 2;
      if (headingAfter > headingBefore) headingRight += 180;
      headingRight += 360;

      headingRight = headingRight % 360;

      addPoint(headingRight, currentLatLng);
    }

    if (nextLatLng != null) {
      headingRight = mp.SphericalUtil.computeHeading(
              mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
              mp.LatLng(nextLatLng.latitude, nextLatLng.longitude)) +
          90;
      addPoint(headingRight, currentLatLng);
    }

    if (lastLatLng == null && nextLatLng != null) {
      for (var i = 180; i >= 0; i -= 10) {
        var heading = mp.SphericalUtil.computeHeading(
                mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
                mp.LatLng(nextLatLng.latitude, nextLatLng.longitude)) +
            90 -
            i;
        addPoint(heading, currentLatLng, right: false);
      }
    }

    if (lastLatLng != null && nextLatLng == null) {
      for (var i = 0; i <= 180; i += 10) {
        var heading = mp.SphericalUtil.computeHeading(
                mp.LatLng(currentLatLng.latitude, currentLatLng.longitude),
                mp.LatLng(lastLatLng.latitude, lastLatLng.longitude)) -
            90 -
            i;
        addPoint(heading, currentLatLng, left: false);
      }
    }
  }

  // polylineLeft = Polyline(
  //     points: polyLeft, color: Colors.yellow.withOpacity(1), strokeWidth: 2);

  // polylineRight = Polyline(
  //     points: polyRight, color: Colors.green.withOpacity(1), strokeWidth: 2);

  List<LatLng> reversedList = List.from(polyRight.reversed);
  List<LatLng> polygonCoords = List.from(polyLeft)..addAll(reversedList);

  return polygonCoords;
  //return Polygon(points: polys, color: Colors.blue.withOpacity(0.35));

  // List<mp.LatLng> latlngs = [];
  // for (LatLng element in polys) {
  //   latlngs.add(mp.LatLng(element.latitude, element.longitude));
  // }

  // num area = mp.SphericalUtil.computeArea(latlngs);

  //return [polylineLeft, polylineRight, complexPoly];
}

bool checkNecessaryDistance(LatLng lastLatLng, LatLng currentLatLng) {
  num requiredDistance = 5;
  num distance = mp.SphericalUtil.computeDistanceBetween(
      mp.LatLng(lastLatLng.latitude, lastLatLng.longitude),
      mp.LatLng(currentLatLng.latitude, currentLatLng.longitude));

  return distance >= requiredDistance;
}
