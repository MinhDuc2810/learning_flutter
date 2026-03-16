import 'dart:convert';
import 'dart:io';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:base_flutter/utils/logger.dart';
import 'package:http/http.dart' as http;

const baseUrl = "https://bavbomstg.onschool.edu.vn";

class AssignAPI {
  static Future submissionStatus({required int assignId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_assign_get_submission_status";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignid=$assignId";
    final response = await OnsClient.get(url);
    logger("AssignAPI:submissionStatus $url");
    return jsonDecode(response.body);
  }

  static Future saveSubmission({
    required int assignId,
    required int itemid,
  }) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_assign_save_submission";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignmentid=$assignId";
    url = "$url&plugindata[files_filemanager]=$itemid";

    final response = await OnsClient.post(url);
    logger("AssignAPI:saveSubmission $url");
    return jsonDecode(response.body);
  }

  static Future submit({required int assignId, required fileItemId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_assign_save_submission";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignmentid=$assignId";
    url = "$url&plugindata[files_filemanager]=$fileItemId";
    final response = await OnsClient.get(url);
    logger("AssignAPI:submit $url");
    return jsonDecode(response.body);
  }

  static Future delete({required int fileId, required int confirm}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=report_finalgrade_delete_file";
    url = "$url&moodlewsrestformat=json";
    url = "$url&fileid=$fileId";
    url = "$url&confirm=$confirm";
    final response = await OnsClient.get(url);
    logger("AssignAPI:delete $url");
    return jsonDecode(response.body);
  }

  static Future getGrade({required int assignId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=report_finalgrade_get_assign_final_grade";
    url = "$url&moodlewsrestformat=json";
    url = "$url&assignid=$assignId";
    final response = await OnsClient.get(url);
    logger("AssignAPI:getGrade $url");
    return jsonDecode(response.body);
  }

  static Future uploadFile(
      {required String token,
      required String filePath,
      String itemid = ''}) async {
    logger(filePath);
    String url = "$baseUrl/webservice/upload.php";
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll(
        {HttpHeaders.contentTypeHeader: 'application/json', 'token': token});
    request.fields['token'] = token;
    request.fields['filearea'] = 'draft';
    request.fields['filepath'] = '/';
    request.fields['component'] = 'user';
    request.fields['itemid'] = itemid;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));
    http.Response response =
        await http.Response.fromStream(await request.send());
    logger("Call api upload image $url");
    return jsonDecode(response.body);
  }

  static Future deleteDraftFile(
      {required int itemid, required String filename}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=core_files_delete_draft_file";
    url = "$url&moodlewsrestformat=json";
    url = "$url&draftitemid=$itemid"; // Note: standard Moodle uses draftitemid
    url = "$url&filename=$filename";
    url = "$url&filepath=/";
    final response = await OnsClient.get(url);
    logger("AssignAPI:deleteDraftFile $url");
    return jsonDecode(response.body);
  }
}
