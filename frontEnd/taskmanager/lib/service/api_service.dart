import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = '';
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
}
