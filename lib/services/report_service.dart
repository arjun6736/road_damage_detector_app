import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ReportService {
  static const String baseUrl = "https://routefixer.dpdns.org/api";

  // =============================
  // GET REPORTS
  // =============================
  Future<List<dynamic>> getReports(String firebaseUid) async {
    final url = Uri.parse("$baseUrl/reports/$firebaseUid/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load reports");
    }
  }

  // =============================
  // SEND REPORT
  // =============================
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

    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();

    // Add text fields
    request.fields['damage_type'] = title;

    request.fields['description'] = description;

    request.fields['gps'] = gps;

    request.fields['time'] = time;

    // IMPORTANT: send token
    request.fields['fcm_token'] = token ?? "";

    // Add image
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',

        imageFile.path,

        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }
}
