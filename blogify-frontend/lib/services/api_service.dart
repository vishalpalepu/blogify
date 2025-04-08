// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Replace with your actual backend URL (e.g., http://10.0.2.2:3000 if using an emulator)
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // User endpoints
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/users/signin');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> signup(
    String fullname,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/users/signup');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "email": email,
        "password": password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Signup failed: ${response.body}");
    }
  }

  // Blogs endpoints
  static Future<List<dynamic>> getBlogs() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/blogs');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load blogs");
    }
  }

  static Future<Map<String, dynamic>> getBlog(String blogId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/blogs/$blogId');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load blog");
    }
  }

  static Future<Map<String, dynamic>> addBlog(
    String title,
    String body,
    File? imageFile,
  ) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/blogs');
    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields['title'] = title;
    request.fields['body'] = body;
    if (imageFile != null) {
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: imageFile.path.split("/").last,
      );
      request.files.add(multipartFile);
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add blog: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> addComment(
    String blogId,
    String content,
  ) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/blogs/$blogId/comment');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"content": content}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add comment: ${response.body}");
    }
  }
}
