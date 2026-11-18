import 'package:flutter/material.dart';
import 'package:lister/screen/activity_list_screen.dart';

void main() {
  runApp(const ListerApp());
}

class ListerApp extends StatelessWidget {
  const ListerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lister',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ActivityListScreen(),
    );
  }
}
