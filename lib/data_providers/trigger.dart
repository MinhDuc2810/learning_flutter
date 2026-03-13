import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:base_flutter/utils/logger.dart';

const baseUrl = "https://bavbomstg.onschool.edu.vn";

class TriggerAPI {
  static Future viewAssign({required int assignId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_assign_view_assign";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignid=$assignId";
    final response = await OnsClient.get(url);
    logger("TriggerAPI:viewAssign $url");
    return jsonDecode(response.body);
  }
}