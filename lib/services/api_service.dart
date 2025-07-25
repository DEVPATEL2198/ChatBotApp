// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:untitled/constant/api_constant.dart';
import 'package:http/http.dart' as http;

class GoogleApiService {
  static String apiKey = ApiConstant.apiKey;
  static String baseUrl = ApiConstant.baseUrl;

  static Future<String> getApiResponse(List<Map<String, dynamic>> conversation) async {
    try {
      // Each message should be a separate entry in the 'contents' array
      final contents = conversation.map((msg) => {
        "parts": [
          {"text": msg['text']}
        ]
      }).toList();
      final response = await http.post(
        Uri.parse("$baseUrl$apiKey"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": contents
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        //chch if response has condidates and content
        // Check if response has "candidates" and "content"
        if (data.containsKey("candidates") && data["candidates"].isNotEmpty) {
          var firstCandidate = data["candidates"][0];

          if (firstCandidate.containsKey("content") &&
              firstCandidate["content"].containsKey("parts") &&
              firstCandidate["content"]["parts"].isNotEmpty) {
            return firstCandidate["content"]["parts"][0]["text"] ??
                "AI response was empty.";
          }
        }
        return "AI did not return any content.";
      } else {
        return "Error:  {response.statusCode} -  {response.body}";
      }
    } catch (e) {
      print("Error=> $e");
      return "Error: $e";
    }
  }
}