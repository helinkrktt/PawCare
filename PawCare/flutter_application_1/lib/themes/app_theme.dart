//lib/themes/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Açık tema
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue, // Ana renk paleti
    scaffoldBackgroundColor: Colors.white, // Arka plan rengi
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white, // AppBar yazı rengi
      elevation: 0, // AppBar gölgesi
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black87), // Genel metin rengi
      // Diğer metin stilleri (headline, subtitle, vb.)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Buton rengi
        foregroundColor: Colors.white, // Buton yazı rengi
      ),
    ),
    // Diğer widget stilleri (card, input, vb.)
  );

    // Koyu tema (örnek)
  static ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.grey,
      scaffoldBackgroundColor: Color(0xFF121212), // Koyu arka plan
        appBarTheme: AppBarTheme(
          backgroundColor:  Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
       elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800], // Buton rengi
          foregroundColor: Colors.white,
        ),
      ),
  );


}