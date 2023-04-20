import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import '../models/course_model.dart';
import '../models/user_model.dart';

class EdusignService {
  static User? user;

  /// Login to the edusign server
  static Future<User> login(String username, String password) async {
    Response response = await http.post(
        Uri.parse('https://api.edusign.fr/student/account/getByCredentials'),
        body: {
          'EMAIL': username,
          'PASSWORD': password,
          'LANGUAGE': 'EN',
        });

    var body = json.decode(response.body);

    if (body['status'] != 'success') {
      throw Exception(body['message']);
    }

    return User.fromJson(body['result']);
  }

  /// Get all courses for the given user
  static Future<List<Course>> getCourses(User user) async {
    Response response = await http.get(
        Uri.parse('https://api.edusign.fr/student/courses/getNextUserCourses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        });

    var body = json.decode(response.body);

    if (body['status'] != 'success') {
      throw Exception(body['message']);
    }

    var coursesList = body['result']['data'] as List<dynamic>;

    return coursesList
        .map((courseJson) => Course.fromJson(courseJson))
        .toList();
  }

  static Future<bool> validateCourse(
      User user, Course course, String code, String signature) async {
    Response response = await http.post(
      Uri.parse('https://api.edusign.fr/student/courses/scanQRCode-v2'),
      headers: {'Authorization': 'Bearer ${user.token}', 'QrCodeId': code},
      body: {
        'courseId': course.id,
        'Model': 'Fluttersign',
        'signature': 'data:image/png;base64,$signature'
      },
    );

    var body = json.decode(response.body);

    return body['status'] == 'success';
  }

  static Future<Course> getCourseById(User user, String id) async {
    Response response = await http
        .get(Uri.parse('https://api.edusign.fr/student/courses/$id'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${user.token}',
    });

    var body = json.decode(response.body);

    if (body['status'] != 'success') {
      throw Exception(body['message']);
    }

    return Course.fromJson(body['result']);
  }
}
