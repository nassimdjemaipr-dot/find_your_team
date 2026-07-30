import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/annonces/presentation/pages/fil_annonces_page.dart';

void main() async {
  // Obligatoire avant d'utiliser Firebase au demarrage.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Your Team',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.sombre,
      // Pour l'instant on démarre sur le fil d'annonces.
      // Plus tard : AuthGate (tâche #5) décidera connexion / fil.
      home: const FilAnnoncesPage(),
    );
  }
}
