import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importe a sua tela inicial
// Importe a tela aqui

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Medicamentos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1a237e)),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // A primeira tela que será exibida
    );
  }
}