import 'dart:convert';
import 'package:http/http.dart' as http;

class AssistantService {
  Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));
    try {
      if (response.statusCode == 200) {
        String responseJson = response.body;
        var decodeData = jsonDecode(responseJson);
        return decodeData;
      } else {
        return 'failed';
      }
    } catch (e) {
      return 'failed';
    }
  }
}
