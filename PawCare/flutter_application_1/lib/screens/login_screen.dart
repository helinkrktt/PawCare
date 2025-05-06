// lib/screens/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Giriş formu buraya gelecek.',
            style: TextStyle(fontSize: 18),
          ),
          // TODO: E-posta, şifre alanları ve giriş butonu ekle
        ),
      ),
    );
  }
}