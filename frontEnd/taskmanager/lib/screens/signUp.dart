import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  SignUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(),
          TextFormField(controller: emailController),
          TextFormField(controller: passwordController),
          TextFormField(controller: nameController)
        ],
      ),
    );
  }
}
