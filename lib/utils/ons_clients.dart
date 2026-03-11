import 'dart:convert';

import 'package:base_flutter/constants/storage_key.dart';
import 'package:base_flutter/data_providers/auth.dart';
import 'package:base_flutter/data/models/token.dart';
import 'package:base_flutter/main.dart';
import 'package:base_flutter/utils/local_storage.dart';
import 'package:base_flutter/utils/logger.dart';
import 'package:base_flutter/utils/toast.dart';
import 'package:http/http.dart' as http;

void goToLogin() {
  navigationKey.currentState?.pushReplacementNamed("/login");
}

String buildAuthUrl(String url, String token) {
  if (url.contains("?")) {
    url = "$url&wstoken=$token";
  } else {
    url = "$url?wstoken=$token";
  }
  return url;
}

class OnsClient {
  static Future get(String url,
      {Map<String, String>? headers, bool requiredAuth = true}) async {
    try {
      headers = headers ?? <String, String>{};
      if (requiredAuth) {
        String token = await LocalStorage.getString(StorageKey.token) ?? "";
        // logger(token);
        String authUrl = buildAuthUrl(url, token);
        var response = await http
            .get(Uri.parse(authUrl), headers: headers)
            .timeout(const Duration(seconds: 60));
        final responseJson = jsonDecode(response.body);
        if (responseJson is! List &&
            responseJson['errorcode'] == 'invalidtoken') {
          logger("Hết phiên đăng nhập, đăng nhập lại tự động!");
          String username =
              await LocalStorage.getString(StorageKey.username) ?? "";
          String password =
              await LocalStorage.getString(StorageKey.password) ?? "";

          if (username.isNotEmpty && password.isNotEmpty) {
            logger("OnsClient re-login");
            final newAuthResponse =
                await AuthAPI.login(username: username, password: password);
            Token newToken = Token.fromJson(newAuthResponse);
            if (newToken.isEmpty()) {
              await LocalStorage.remove(StorageKey.username);
              await LocalStorage.remove(StorageKey.password);
              await LocalStorage.remove(StorageKey.token);
              goToLogin();
            } else {
              await LocalStorage.putString(StorageKey.token, newToken.token);
              String newAuthUrl = buildAuthUrl(url, newToken.token);
              response = await http
                  .get(Uri.parse(newAuthUrl), headers: headers)
                  .timeout(const Duration(seconds: 60));
            }
          } else {
            goToLogin();
          }
        }
        return response;
      }
      var response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));
      return response;
    } catch (e) {
      if (e.toString().contains("host lookup")) {
        Toast.show("Vui lòng kiểm tra lại kết nối mạng");
      }
      logger(e);
      return e;
    }
  }

  static Future post(String url,
      {Map<String, String>? headers,
      dynamic body,
      dynamic encoding,
      bool requiredAuth = true}) async {
    headers = headers ?? <String, String>{};
    try {
      if (requiredAuth) {
        String token = await LocalStorage.getString(StorageKey.token) ?? "";
        // logger(token);
        String authUrl = buildAuthUrl(url, token);
        var response = await http
            .post(Uri.parse(authUrl),
                headers: headers, body: body, encoding: encoding)
            .timeout(const Duration(seconds: 60));

        final responseJson = jsonDecode(response.body);
        if (responseJson['errorcode'] == 'invalidtoken') {
          logger("Hết phiên đăng nhập, đăng nhập lại tự động!");
          String username =
              await LocalStorage.getString(StorageKey.username) ?? "";
          String password =
              await LocalStorage.getString(StorageKey.password) ?? "";

          if (username.isNotEmpty && password.isNotEmpty) {
            logger("OnsClient re-login");
            final newAuthResponse =
                await AuthAPI.login(username: username, password: password);
            Token newToken = Token.fromJson(newAuthResponse);
            if (newToken.isEmpty()) {
              await LocalStorage.remove(StorageKey.username);
              await LocalStorage.remove(StorageKey.password);
              await LocalStorage.remove(StorageKey.token);
              goToLogin();
            } else {
              await LocalStorage.putString(StorageKey.token, newToken.token);
              String newAuthUrl = buildAuthUrl(url, newToken.token);
              response = await http
                  .post(Uri.parse(newAuthUrl),
                      headers: headers, body: body, encoding: encoding)
                  .timeout(const Duration(seconds: 60));
            }
          } else {
            goToLogin();
          }
        }

        return response;
      }

      var response = await http
          .post(Uri.parse(url),
              headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 60));
      return response;
    } catch (e) {
      if (e.toString().contains("host lookup")) {
        Toast.show("Vui lòng kiểm tra lại kết nối mạng");
      }
      return e;
    }
  }
}
