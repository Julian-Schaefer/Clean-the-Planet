import 'dart:io';

import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> askForBatteryOptimizationPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    var ignoreBatteryOptimizationsStatus =
        await Permission.ignoreBatteryOptimizations.status;
    while (ignoreBatteryOptimizationsStatus != PermissionStatus.granted) {
      if (await Permission.ignoreBatteryOptimizations.isPermanentlyDenied) {
        openAppSettings();
        return false;
      } else {
        ignoreBatteryOptimizationsStatus =
            await Permission.ignoreBatteryOptimizations.request();
      }
    }

    return true;
  }

  static Future<bool> askForLocationPermission(loc.Location? location) async {
    bool serviceEnabled = await location!.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    var locationStatus = await location.hasPermission();
    while (locationStatus != loc.PermissionStatus.granted) {
      if (locationStatus == loc.PermissionStatus.deniedForever) {
        openAppSettings();
        return false;
      } else {
        locationStatus = await location.requestPermission();
      }
    }

    return true;
  }
}
