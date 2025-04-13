// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taskmanager/service/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _userProfile = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _apiService.getUserProfile();

    setState(() {
      _userProfile = response.containsKey('user') ? response['user'] : {};
      _isLoading = false;
    });
  }

  Future<void> _updateAvatar() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _apiService.updateAvatar(File(pickedImage.path));

        if (result.containsKey('message') &&
            result['message'] == 'Avatar updated successfully') {
          _loadUserProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Avatar updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update avatar')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _updateAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _userProfile['avatar'] != null
                              ? CachedNetworkImageProvider(
                                  _userProfile['avatar']['url'] ?? '')
                              : null,
                          child: _userProfile['avatar'] == null
                              ? Text(
                                  (_userProfile['name'] ?? 'U')[0]
                                      .toUpperCase(),
                                  style: TextStyle(fontSize: 40),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tap to change profile picture',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 30),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Name'),
                      subtitle: Text(_userProfile['name'] ?? 'Not available'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email'),
                      subtitle: Text(_userProfile['email'] ?? 'Not available'),
                    ),
                  ),
                  SizedBox(height: 20),
                  // You can add more profile details or actions here
                ],
              ),
            ),
    );
  }
}
