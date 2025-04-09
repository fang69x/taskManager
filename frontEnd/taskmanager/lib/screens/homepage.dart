import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            Container(
              height: 100,
              color: const Color.fromARGB(255, 255, 199, 29),
            ),
            Text("Hello"),
          ],
        ),
      ),
    );
  }
}
