// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Kayıt formu buraya gelecek.',
            style: TextStyle(fontSize: 18),
          ),
          // TODO: E-posta, şifre, şifre tekrarı alanları ve kayıt butonu ekle
        ),
      ),
    );
  }
}