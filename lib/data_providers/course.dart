import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:http/http.dart' as http;

const schoolnameCst = "bav";
const baseUrl = "https://bavbomstg.onschool.edu.vn";

class CourseAPI {
  static Future<Map<String, dynamic>> getCourseList() async {
    final response = await OnsClient.get(
      '$baseUrl/webservice/rest/server.php?wsfunction=core_course_get_enrolled_courses_by_timeline_classification&moodlewsrestformat=json&classification=all&search',
    );

    if (response is http.Response && response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load course list');
    }
  }

  static Future detailCourse({required String courseId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=core_course_get_contents";
    url = "$url&moodlewsrestformat=json";
    url = "$url&courseid=$courseId";
    final response = await OnsClient.get(url);
    return jsonDecode(response.body);
  }
}
