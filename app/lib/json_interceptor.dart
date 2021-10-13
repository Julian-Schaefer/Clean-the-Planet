import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_interceptor/http_interceptor.dart';

class JsonInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    Map<String, String> headers = await getHeaders();
    data.headers.addAll(headers);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.headers != null &&
        data.headers![HttpHeaders.contentTypeHeader] != null &&
        data.headers![HttpHeaders.contentTypeHeader]!
            .startsWith("application/json")) {
      if (data.body != null) {
        data.body = utf8.decode(data.toHttpResponse().bodyBytes);
      }

      data.headers![HttpHeaders.contentTypeHeader] =
          'application/json; charset=utf-8';
    }

    return data;
  }

  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {};

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User is not logged in.");
    }

    var token = await currentUser.getIdToken();

    headers["Authorization"] = "Bearer " + token;
    headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=utf-8';

    return headers;
  }
}
