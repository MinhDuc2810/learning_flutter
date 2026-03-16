import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:base_flutter/utils/logger.dart';

const baseUrl = "https://bavbomstg.onschool.edu.vn";

class ResultAPI {
  static Future list({String status = "", String condition = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_user_grade_overview";
    url = "$url&moodlewsrestformat=json";
    if (status.isNotEmpty) {
      url = "$url&status=$status";
    }
    if (condition.isNotEmpty) {
      url = "$url&condition=$condition";
    }
    final response = await OnsClient.get(url);
    return jsonDecode(response.body);
  }

  static Future detail({required String courseId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_user_grade_detail_by_course";
    url = "$url&courseid=$courseId";
    url = "$url&moodlewsrestformat=json";
    final response = await OnsClient.get(url);
    logger("ResultAPI:detail $url");
    return jsonDecode(response.body);
  }
}