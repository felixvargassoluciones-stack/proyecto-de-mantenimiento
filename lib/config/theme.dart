import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores basada en Control de Obra
  static const Color primaryDark = Color(0xFF0F2537); // Azul marino oscuro para el Sidebar
  static const Color backgroundLight = Color(0xFFF4F6F9); // Gris claro neutro para el fondo
  static const Color cardWhite = Color(0xFFFFFFFF); // Blanco puro para los módulos
  static const Color accentBlue = Color(0xFF1E88E5); // Azul secundario para elementos seleccionados
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryDark,
      cardColor: cardWhite,
      colorScheme: ColorScheme.light(
        primary: primaryDark,
        secondary: accentBlue,
        surface: cardWhite,
      ),
    );
  }
}
