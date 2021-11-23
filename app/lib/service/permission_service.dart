import 'dart:io';

import 'package:clean_the_planet/dialogs/huawei_battery_help_dialog.dart';
import 'package:clean_the_planet/dialogs/samsung_battery_help_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  final String batteryOptimizationAskedKey = "BATTERY_OPTIMIZATION_ASKED";

  Future<bool> askForBatteryOptimizationPermission(BuildContext context) async {
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
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.manufacturer != null) {
        switch (androidInfo.manufacturer) {
          case "samsung":
            await _showSamsungBatteryOptimizationHelp(context);
            break;
          case "huawei":
            await _showHuaweiBatteryOptimizationHelp(context);
            break;
        }
      }
    }

    return true;
  }

  Future<bool> askForLocationPermission(loc.Location? location) async {
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

  Future<void> _showSamsungBatteryOptimizationHelp(BuildContext context) async {
    await Navigator.of(context).push(
      SamsungBatteryHelpDialog(onComplete: () {
        Navigator.pop(context);
      }),
    );
  }

  Future<void> _showHuaweiBatteryOptimizationHelp(BuildContext context) async {
    await Navigator.of(context).push(
      HuaweiBatteryHelpDialog(onComplete: () {
        Navigator.pop(context);
      }),
    );
  }
}
