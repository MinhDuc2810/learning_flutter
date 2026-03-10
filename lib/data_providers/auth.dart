import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = "https://bavbomstg.onschool.edu.vn";

class AuthAPI {
  static Future login(
      {required String username, required String password}) async {
    String url = "$baseUrl/login/token.php";
    Map params = <String, dynamic>{};
    params['username'] = username;
    params['password'] = password;
    params['service'] = 'moodle_mobile_app';
    params['rememberusername'] = "1";
    final response = await http.post(Uri.parse(url), body: params);
    return jsonDecode(response.body);
  }
}
