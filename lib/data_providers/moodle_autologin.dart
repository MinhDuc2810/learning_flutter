import 'dart:convert';
import 'package:base_flutter/utils/ons_clients.dart';
import 'package:base_flutter/data_providers/course.dart';
import 'package:base_flutter/utils/logger.dart';

class MoodleAutologinAPI {
  static Future<String> getAutologinUrl(String targetUrl) async {
    try {
      // 1. Get site info to get userid
      final siteInfoResponse = await OnsClient.post(
          '$baseUrl/webservice/rest/server.php?wsfunction=core_webservice_get_site_info&moodlewsrestformat=json');
      final siteInfo = jsonDecode(siteInfoResponse.body);
      final userId = siteInfo['userid'];

      // 2. Get autologin key
      final keyResponse = await OnsClient.post(
          '$baseUrl/webservice/rest/server.php?wsfunction=tool_mobile_get_autologin_key&moodlewsrestformat=json');
      final keyInfo = jsonDecode(keyResponse.body);

      if (keyInfo != null &&
          keyInfo['key'] != null &&
          keyInfo['autologinurl'] != null) {
        final key = keyInfo['key'];
        final autologinUrl = keyInfo['autologinurl'];

        // 3. Build final auto login url
        final encodedTargetUrl = Uri.encodeComponent(targetUrl);
        return "$autologinUrl?userid=$userId&key=$key&fileurl=$encodedTargetUrl";
      }
      return targetUrl;
    } catch (e) {
      logger("MoodleAutologinAPI error: $e");
      return targetUrl;
    }
  }
}
