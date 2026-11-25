import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Responsi 2 Cuaca',
      home: Scaffold(
        body: Center(
          child: Text('Inisialisasi Aplikasi Cuaca'),
        ),
      ),
    );
  }
}
