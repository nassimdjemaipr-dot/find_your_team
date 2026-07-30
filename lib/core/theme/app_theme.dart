// ============================================================
// THÈME de l'application (couleurs, style global).
// Thème sombre "esport" : fond très sombre + violet accent,
// pour matcher les maquettes Figma.
//
// (Le toggle sombre/clair avec Hive viendra dans la tâche #11.)
// ============================================================
import 'package:flutter/material.dart';

class AppTheme {
  // --- Palette ---
  static const Color fond = Color(0xFF060814); // fond de l'écran
  static const Color surface = Color(0xFF191D31); // fond des cartes
  static const Color bordure = Color(0xFF2B2F4A); // contour des cartes
  static const Color violet = Color(0xFF8F62FF); // couleur principale
  static const Color texteDoux = Color(0xFF9AA0B4); // texte secondaire

  static ThemeData get sombre {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: fond,
      colorScheme: const ColorScheme.dark(
        primary: violet,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: fond,
        elevation: 0,
        centerTitle: false,
      ),
      // Style par défaut des champs de texte (barre de recherche...).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: texteDoux),
        prefixIconColor: texteDoux,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bordure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bordure),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: violet),
        ),
      ),
    );
  }
}
