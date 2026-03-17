import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logger.dart';
import '../utils/ons_clients.dart';

String schoolname = 'BAV';
String baseUrl = 'https://bavbomstg.onschool.edu.vn';

class QuizServerAPI {
  static Future getAttempt({required String attemptid}) async {
    String url = "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid";
    final response = await http.get(Uri.parse(url));
    logger("QuizServerAPI:getAttempt $url");
    return jsonDecode(response.body);
  }


static Future saveAttempt({
  required String attemptid,
  required String slot,
  required String value,
}) async {
  String url = "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid/answer";

  var response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'slot': slot,
      'position': -1,
      'answer': value,
    }),
  );

  logger("QuizServerAPI:saveAttempt $url");
  logger(response.body);

  return jsonDecode(response.body);
}

static Future flagQuestion({
  required String attemptid,
  required String slot,
}) async {
  
  String url = "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid/$slot/flag";
  final response = await http.post(Uri.parse(url));
  logger("QuizServerAPI:saveAttempt $url");
  return jsonDecode(response.body);
}

  static Future submitAttempt({required String attemptid}) async {
    // String url = "https://dev-quiz-gp.onschool.edu.vn/attempts/submit_attempt?attemptid=$attemptid";
    String url = "https://quiz-server-dev.onschool.edu.vn/$schoolname/attempt/$attemptid/submit";
    final response = await http.post(Uri.parse(url));
    logger("QuizServerAPI:submitAttempt $url");
    return jsonDecode(response.body);
  }

  static Future checkAttempt({required String username}) async {
    String url = "$baseUrl/webservice/rest/server.php?wsfunction=mod_quiz_get_courses_with_practice_tests&moodlewsrestformat=json&username=$username";
    final response = await OnsClient.get(url);
    logger("QuizServerAPI:checkAttempt $url");
    return jsonDecode(response.body);
  }
}