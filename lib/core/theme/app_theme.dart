// ============================================================
// THÈMES de l'application : un sombre et un clair.
//
// Les couleurs ne sont plus ecrites en dur dans les ecrans :
// elles passent par le ColorScheme de Flutter. Du coup, changer
// de theme suffit a repeindre toute l'application.
//
// Correspondance utilisee partout dans le code :
//   surface                 -> le fond de l'ecran
//   surfaceContainerHighest -> le fond des cartes
//   outlineVariant          -> les bordures
//   primary                 -> le violet de la marque
//   onSurfaceVariant        -> le texte secondaire (gris)
// ============================================================
import 'package:flutter/material.dart';

class AppTheme {
  // Le violet de la marque, identique dans les deux themes.
  static const Color violet = Color(0xFF8F62FF);

  // ---------------- THÈME SOMBRE ----------------
  static ThemeData get sombre => _construire(
        const ColorScheme.dark(
          primary: violet,
          onPrimary: Colors.white,
          surface: Color(0xFF060814), // fond de l'ecran
          onSurface: Colors.white, // texte principal
          surfaceContainerHighest: Color(0xFF191D31), // fond des cartes
          onSurfaceVariant: Color(0xFF9AA0B4), // texte secondaire
          outlineVariant: Color(0xFF2B2F4A), // bordures
        ),
      );

  // ---------------- THÈME CLAIR ----------------
  static ThemeData get clair => _construire(
        const ColorScheme.light(
          primary: violet,
          onPrimary: Colors.white,
          surface: Color(0xFFF6F7FB),
          onSurface: Color(0xFF14162B),
          surfaceContainerHighest: Colors.white,
          onSurfaceVariant: Color(0xFF6B7186),
          outlineVariant: Color(0xFFDDE0EA),
        ),
      );

  // Construit un ThemeData a partir d'une palette.
  // Les deux themes partagent exactement le meme style,
  // seules les couleurs changent.
  static ThemeData _construire(ColorScheme couleurs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: couleurs,
      scaffoldBackgroundColor: couleurs.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: couleurs.surface,
        foregroundColor: couleurs.onSurface,
        elevation: 0,
        centerTitle: false,
      ),

      // Style par defaut des champs de texte.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: couleurs.surfaceContainerHighest,
        hintStyle: TextStyle(color: couleurs.onSurfaceVariant),
        prefixIconColor: couleurs.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: couleurs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: couleurs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: couleurs.primary),
        ),
      ),
    );
  }
}

// Raccourci pour recuperer les couleurs du theme courant.
// Au lieu d'ecrire Theme.of(context).colorScheme.primary,
// on ecrit simplement context.couleurs.primary.
extension CouleursContext on BuildContext {
  ColorScheme get couleurs => Theme.of(this).colorScheme;
}