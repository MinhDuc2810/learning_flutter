import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:base_flutter/utils/logger.dart';

const baseUrl = "https://bavbomstg.onschool.edu.vn";

class ForumAPI {
  static Future detailForum(
      {required int id,
      String name = "",
      int page = 1,
      int limit = 10,
      int perPage = 10,
      int sortOrder = 0,
      String userId = "",
      String classification = "",
      int groupId = 0}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_discussions_by_forum";
    url = "$url&moodlewsrestformat=json";
    url = "$url&forumid=$id";
    url = "$url&counttop=3";
    if (userId.isNotEmpty) {
      url = "$url&userid=$userId";
    }
    if (classification.isNotEmpty) {
      url = "$url&classification=$classification";
    }
    final response = await OnsClient.get(url);
    logger("ForumAPI:detailForum $url");
    return jsonDecode(response.body);
  }

  static Future listFollow() async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_followings";
    url = "$url&moodlewsrestformat=json";
    final response = await OnsClient.get(url);
    logger("ForumAPI:listFollow $url");
    return jsonDecode(response.body);
  }

  static Future listPopular({int forumid=0}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_outstands";
    url = "$url&counttop=3";
    url = "$url&moodlewsrestformat=json";
    if (forumid!=0){
      url = "$url&forumid=${forumid.toString()}";
    }
    final response = await OnsClient.get(url);
    logger("ForumAPI:listPopular $url");
    return jsonDecode(response.body);
  }

  static Future viewForum({required int forumId}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_view_forum";
    url = "$url&moodlewsrestformat=json";
    url = "$url&forumid=$forumId";
    final response = await OnsClient.get(url);
    logger("ForumAPI:viewForum $url");
    return jsonDecode(response.body);
  }

  static Future listForums({int page = 1, int limit = 10}) async {
    String url = "$baseUrl/webservice/rest/server.php";
    url = "$url?wsfunction=mod_forum_get_forums";
    url = "$url&moodlewsrestformat=json";
    url = "$url&page=$page";
    url = "$url&limit=$limit";
    final response = await OnsClient.get(url);
    logger("ForumAPI:listForums $url");
    return jsonDecode(response.body);
  }
}
