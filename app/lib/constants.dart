import 'package:clean_the_planet/json_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

String getAPIBaseUrl() {
  if (kReleaseMode) {
    return "https://clean-the-planet.herokuapp.com";
  } else {
    return dotenv.env['API_URL']!;
  }
}

Client getInterceptedClient() {
  return InterceptedClient.build(interceptors: [
    JsonInterceptor(),
  ]);
}
