import 'dart:convert';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';

class JsonInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    data.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';

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
}
