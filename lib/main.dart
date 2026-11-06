import 'package:flutter/material.dart';
import 'package:studypal/layouts/main_app_layout.dart';
import 'package:studypal/pages/pick_location_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PickLocationPage(),
    );
  }
}
