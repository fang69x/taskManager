import 'package:flutter/material.dart';
import 'package:taskmanager/screens/createTaskScreen.dart';
import 'package:taskmanager/screens/homepage.dart';
import 'package:taskmanager/screens/loginPage.dart';
import 'package:taskmanager/screens/profilePage.dart';
import 'package:taskmanager/screens/signUp.dart';
import 'package:taskmanager/screens/taskScreen.dart';
import 'package:taskmanager/service/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<String?>(
          future: ApiService().getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return snapshot.data != null ? TaskScreen() : SignUpPage();
          }),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => SignUpPage(),
        '/tasks': (context) => TaskScreen(),
        '/createTask': (context) => CreateTaskScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
