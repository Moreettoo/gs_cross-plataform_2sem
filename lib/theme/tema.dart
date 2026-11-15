import 'package:flutter/material.dart';

class Tema {
  static const Color primaria = Color(0xFF0B5C63);
  static const Color secundaria = Color(0xFF1E88A8);
  static const Color fundo = Color(0xFFF2F6F6);
  static const Color texto = Color(0xFF14262A);

  static ThemeData criar(bool altoContraste) {
    final esquema = ColorScheme.fromSeed(
      seedColor: primaria,
      brightness: Brightness.light,
    ).copyWith(primary: altoContraste ? const Color(0xFF00363B) : primaria);

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: altoContraste ? Colors.white : fundo,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: altoContraste ? Colors.black : texto,
            displayColor: altoContraste ? Colors.black : texto,
          ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
