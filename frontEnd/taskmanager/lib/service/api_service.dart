import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  // 'for emulator http://10.0.2.2:3000'
  final storage = FlutterSecureStorage();

// get auth token
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

//set auth token
  Future<void> setToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

// clear auth token (logout)
  Future<void> clearToken() async {
    await storage.delete(key: 'auth_token');
  }

  //User registration with avatar
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    File? avatarImage,
  }) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/signUp'));

      // add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

// add avatar
      if (avatarImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarImage.path,
        ));
      }
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = json.decode(responseData);
      if (response.statusCode == 201) {
        await setToken(data['token']);
      }
      return data;
    } catch (e) {
      return {'error ': e.toString()};
    }
  }

  // User Login
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        await setToken(data['token']);
      }
      return data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  //get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

// get all tasks
  Future<List<dynamic>> getAllTasks() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  //create task

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/create'),
        headers: {
          'Content-Type': 'appilcation/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

//update task
  Future<Map<String, dynamic>> updateTask({
    required String id,
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        headers: {
          'Content-Type': 'appilcation/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(taskData),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

//Delete Task

  Future<Map<String, dynamic>> deleteTask(String id) async {
    try {
      final token = await getToken();
      final response =
          await http.delete(Uri.parse('$baseUrl/tasks/remove/$id'), headers: {
        'Content-Type': 'appilcation/json',
        'Authorization': 'Bearer $token',
      });
      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
