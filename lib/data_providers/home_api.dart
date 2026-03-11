import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:http/http.dart' as http;

const schoolnameCst = "bav";
const baseUrl = "https://bavbomstg.onschool.edu.vn";

class HomeAPI {
  Future<Map<String, dynamic>> getlogologin() async {
    final response = await OnsClient.get(
      '$baseUrl/local/appmobile/getlogologin.php?schoolname=$schoolnameCst',
      requiredAuth: false,
    );

    if (response is http.Response && response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load getlogologin');
    }
  }

  Future<Map<String, dynamic>> getLogoHome() async {
    final response = await OnsClient.get(
      '$baseUrl/local/appmobile/getlogohome.php?schoolname=$schoolnameCst',
      requiredAuth: false,
    );

    if (response is http.Response && response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load getlogohome');
    }
  }
}
