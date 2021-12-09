import 'dart:io';

import 'package:flutter/material.dart';

class ExceptionLocalizationService {
  String getMessageFromException(BuildContext context, Exception exception) {
    switch (exception.runtimeType) {
      case SocketException:
        return "Could not connect to server 😑";
      case FormatException:
        return "Bad response format 👎";
      default:
        return "An unexpected Error occured";
    }
  }
}
