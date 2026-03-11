import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';


const baseUrl = "https://bavbomstg.onschool.edu.vn";

class MissionAPI {
 static Future listCompletion(
      {String courseId = "",
      String timeline = "all",
      String status = "",
      String search = "",
      String fromTime = "",
      String toTime = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=core_completion_get_activities_completion_status";
    url = "$url&timeline=$timeline";
    if (courseId.isNotEmpty) {
      url = "$url&courseid=$courseId";
    }
    if (status.isNotEmpty) {
      url = "$url&state=$status";
    }
    if (search.isNotEmpty) {
      url = "$url&search=$search";
    }
    url = "$url&moodlewsrestformat=json";
    if (fromTime.isNotEmpty){
      url = "$url&timefrom=$fromTime";
    }
    if (toTime.isNotEmpty){
      url = "$url&timeto=$toTime";
    }
    final response = await OnsClient.get(url);
    return jsonDecode(response.body);
  }
}