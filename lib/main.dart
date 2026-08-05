import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/stockage/preferences_service.dart';
import 'core/stockage/favoris_service.dart';
import 'core/stockage/profil_joueur_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive AVANT tout (obligatoire pour la persistance).
  await Hive.initFlutter();

  // Stockage distant : Firestore + authentification.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Stockage local : Hive (theme, favoris, infos du joueur).
  await PreferencesService.initialiser();
  await FavorisService.initialiser();
  await ProfilJoueurService.initialiser();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder ecoute la box Hive : des que l'utilisateur
    // change de theme, seule cette partie se reconstruit et toute
    // l'application change de couleurs.
    return ValueListenableBuilder<Box>(
      valueListenable: PreferencesService.ecouteur,
      builder: (context, box, _) {
        final sombre = PreferencesService.themeSombre;

        return MaterialApp(
          title: 'Find Your Team',
          debugShowCheckedModeBanner: false,
          theme: sombre ? AppTheme.sombre : AppTheme.clair,
          // L'AuthGate decide : connexion si personne, sinon la HomePage.
          home: const AuthGate(),
        );
      },
    );
  }
}
