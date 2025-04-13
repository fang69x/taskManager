// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Replace with your API base URL
  final String baseUrl =
      'http://10.0.2.2:3000/api'; // Use your machine's IP for local development
  final storage = FlutterSecureStorage();

  // Get auth token
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // Set auth token
  Future<void> setToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  // Clear auth token (logout)
  Future<void> clearToken() async {
    await storage.delete(key: 'auth_token');
  }

  // User Registration with Avatar

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    File? avatarImage,
  }) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/signup'));

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

      // Add avatar if provided
      if (avatarImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarImage.path,
        ));
      }

      // Add headers if required by your API
      request.headers['Content-Type'] = 'multipart/form-data';

      // Print request details for debugging
      print('Sending registration request to: ${request.url}');
      print('Request fields: ${request.fields}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Print response for debugging
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      var data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (data.containsKey('token')) {
          await setToken(data['token']);
          print('Token saved: ${data['token']}');
        } else {
          print('Warning: No token found in response');
        }
      }

      return data;
    } catch (e) {
      print('Registration error: $e');
      return {'error': e.toString()};
    }
  }

  // User Login
  // Update the loginUser method in api_service.dart

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Login request to: $baseUrl/auth/login');
      print('Email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('token')) {
          await setToken(data['token']);
          print(
              'Token saved successfully: ${data['token'].substring(0, 10)}...');
        } else {
          print('Warning: No token found in successful login response');
        }
      } else {
        print('Login failed with status code: ${response.statusCode}');
      }

      return data;
    } catch (e) {
      print('Login error: $e');
      return {'error': e.toString()};
    }
  }

  // Update User Avatar
  Future<Map<String, dynamic>> updateAvatar(File avatarImage) async {
    try {
      final token = await getToken();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatarImage.path,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      return json.decode(responseData);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Get User Profile
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

  // Get All Tasks
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

  // Create Task
  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
  }) async {
    try {
      final token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/tasks/create'),
        headers: {
          'Content-Type': 'application/json',
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

  // Update Task
  Future<Map<String, dynamic>> updateTask({
    required String id,
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final token = await getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/tasks/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(taskData),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Delete Task
  Future<Map<String, dynamic>> deleteTask(String id) async {
    try {
      final token = await getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/remove/$id'),
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
}
