import 'dart:convert';
import 'dart:io';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:base_flutter/utils/logger.dart';

const baseUrl = "https://bavbomstg.onschool.edu.vn";

class QuizAPI {
  static Future startQuiz(
      {required int quizId,
      String password = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_start_attempt";
    url = "$url&moodlewsrestformat=json";
    url = "$url&quizid=$quizId";
    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    final response = await OnsClient.get(url);
    logger("QuizAPI:startQuiz $url");
    return jsonDecode(response.body);
  }

  static Future quizContent(
      {required int attemptId,
      int page = 0,
      String password = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_get_attempt_data";
    url = "$url&moodlewsrestformat=json";
    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    url = "$url&attemptid=$attemptId";
    url = "$url&page=$page";
    final response = await OnsClient.get(url);
    logger("QuizAPI:quizContent $url");
    return jsonDecode(response.body);
  }

  static Future checkQuizHistoryReviewOptions(
      {required int quizId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_get_combined_review_options";
    url = "$url&moodlewsrestformat=json";
    url = "$url&quizid=$quizId";
    final response = await OnsClient.get(url);
    logger("QuizAPI:historyQuizReviewOptions $url");
    return jsonDecode(response.body);
  }

  static Future historyQuiz(
      {required int quizId, String status = "all"}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_get_user_attempts";
    url = "$url&moodlewsrestformat=json";
    url = "$url&includepreviews=1";
    url = "$url&quizid=$quizId";
    url = "$url&status=$status";
    final response = await OnsClient.get(url);
    logger("QuizAPI:historyQuiz $url");
    return jsonDecode(response.body);
  }

  static Future historyAttempt({required int attemptId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=local_quiz_get_attempt_review";
    url = "$url&moodlewsrestformat=json";
    url = "$url&attemptid=$attemptId";
    final response = await OnsClient.get(url);
    logger("QuizAPI:historyAttempt $url");
    return jsonDecode(response.body);
  }

  static Future courseModuleQuiz(
      {required int cmid, required int courseId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=local_core_get_grade_modules";
    url = "$url&moodlewsrestformat=json";
    url = "$url&module[cmid]=$cmid";
    url = "$url&module[courseid]=$courseId";
    final response = await OnsClient.get(url);
    logger("QuizAPI:courseModuleQuiz $url");
    return jsonDecode(response.body);
  }

  static Future submitQuiz(
      {required int attemptId,
      required List data,
      String password = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_process_attempt";
    url = "$url&moodlewsrestformat=json";
    url = "$url&attemptid=$attemptId";
    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    url = "$url&finishattempt=1";
    // url = "$url&timeup=0";
    Map<dynamic, dynamic> dataBody = {};
    for (var i = 0; i < data.length; i++) {
      dataBody["data[$i][name]"] = "${data[i]['name']}";
      dataBody["data[$i][value]"] = "${data[i]['value']}";
    }
    logger("dataBody");
    logger(dataBody);
    final response = await OnsClient.post(url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: dataBody,
        encoding: Encoding.getByName('utf-8'));
    logger("QuizAPI:submitQuiz $url");
    return jsonDecode(response.body);
  }

  static Future autoSaveQuiz(
      {required int attemptId,
      required List data,
      String password = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_save_attempt";
    url = "$url&moodlewsrestformat=json";
    url = "$url&attemptid=$attemptId";
    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    Map<dynamic, dynamic> dataBody = {};
    for (var i = 0; i < data.length; i++) {
      dataBody["data[$i][name]"] = "${data[i]['name']}";
      dataBody["data[$i][value]"] = "${data[i]['value']}";
    }
    logger("dataBody");
    logger(dataBody);
    final response = await OnsClient.post(url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: dataBody,
        encoding: Encoding.getByName('utf-8'));
    logger("QuizAPI:autoSaveQuiz $url");
    return jsonDecode(response.body);
  }

  static Future flagQuestion(
      {required String questionid,
      required String qubaid,
      required String qaid,
      required String slot,
      required String checksum,
      required String newstate,
      String password = ""}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=core_question_update_flag";
    url = "$url&moodlewsrestformat=json";
    url = "$url&qubaid=$qubaid";
    url = "$url&questionid=$questionid";
    url = "$url&qaid=$qaid";
    url = "$url&slot=$slot";
    url = "$url&checksum=$checksum";
    url = "$url&newstate=$newstate";

    if (password.isNotEmpty) {
      url = "$url&preflightdata[0][name]=quizpassword";
      url = "$url&preflightdata[0][value]=$password";
    }
    logger("dataBody");

    final response = await OnsClient.get(url);
    logger("QuizAPI:autoSaveQuiz $url");
    return jsonDecode(response.body);
  }

  // static Future saveQuizFace({
  //   required List<File> images,
  //   required int courseId,
  //   required int quizId,
  //   required int userId,
  //   required int attemptId,
  //   required int screenshotId,
  //   required int cmid,
  // }) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('${ListApi.faceDomain}/savecamshot'),
  //   );
  //   request.fields['courseid'] = "$courseId";
  //   request.fields['quizid'] = "$quizId";
  //   request.fields['userid'] = "$userId";
  //   request.fields['attemptid'] = "$attemptId";
  //   request.fields['screenshotid'] = "$screenshotId";
  //   request.fields['cmid'] = "$cmid";
  //   request.fields['context'] = 'quiz';
  //   for (int i = 0; i < images.length; i++) {
  //     logger(images[i].path);
  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         'camshots[$i]',
  //         images[i].path,
  //       ),
  //     );
  //   }
  //   logger(request.fields);

  //   http.Response response =
  //   await http.Response.fromStream(await request.send());
  //   logger("Auto save quiz face");
  //   return jsonDecode(response.body);
  // }

  static Future submitFlag(
    {required List<Map<String, String>> flagData}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_quiz_update_flag";
    url = "$url&moodlewsrestformat=json";
    Map<String, String> body = {};
    for (int i = 0; i < flagData.length; i++) {
      final item = flagData[i];
      item.forEach((key, value) {
        body['flag_data[$i][$key]'] = value.toString();
      });
    }
    logger("QuizAPI:submitFlag $body");
    final response = await OnsClient.post(
          url, 
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: body,);
    logger("QuizAPI:submitFlag $url");
    return jsonDecode(response.body);
  }
}
