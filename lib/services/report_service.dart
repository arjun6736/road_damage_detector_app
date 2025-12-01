import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ReportService {
  static const String baseUrl = "http://10.105.122.156:8000/api";

  // 🔹 GET reports
  Future<List<dynamic>> getReports(String firebaseUid) async {
    final url = Uri.parse("$baseUrl/reports/$firebaseUid/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load reports");
    }
  }

  // 🔹 POST report (image + text)
  Future<http.Response> sendReport({
    required String firebaseUid,
    required File imageFile,
    required String title,
    required String description,
    required String gps,
    required String time,
  }) async {
    final url = Uri.parse("$baseUrl/reports/$firebaseUid/");

    final request = http.MultipartRequest("POST", url);

    // Normal fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['gps'] = gps;
    request.fields['time'] = time;

    // Image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedRes = await request.send();
    final response = await http.Response.fromStream(streamedRes);

    return response;
  }
}
