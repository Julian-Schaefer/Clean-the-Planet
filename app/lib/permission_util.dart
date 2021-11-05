import 'dart:io';

import 'package:location/location.dart' as loc;
import 'package:notification_troubleshoot/notification_troubleshoot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionUtil {
  static const String batteryOptimizationAskedKey =
      "BATTERY_OPTIMIZATION_ASKED";

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

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? alreadyAskedBattery =
        sharedPreferences.getBool(batteryOptimizationAskedKey);
    if (alreadyAskedBattery == null || !alreadyAskedBattery) {
      final List<NotificationTroubleshootActions> availableActions =
          await NotificationTroubleshoot.availableActions;
      for (var availableAction in availableActions) {
        if (availableAction ==
            NotificationTroubleshootActions.actionPowersaving) {
          NotificationTroubleshoot.startIntent(availableAction);
          sharedPreferences.setBool(batteryOptimizationAskedKey, true);
        }
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
