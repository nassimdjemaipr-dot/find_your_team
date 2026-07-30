// ============================================================
// AUTH GATE : le "portier" de l'application.
// Il ecoute en permanence l'etat de connexion Firebase :
//   - personne connecte  -> AuthPage (connexion / inscription)
//   - quelqu'un connecte -> FilAnnoncesPage
// Grace au StreamBuilder, la bascule est automatique :
// pas besoin de Navigator apres une connexion ou une deconnexion.
// ============================================================
import 'package:flutter/material.dart';
import '../../../annonces/presentation/pages/fil_annonces_page.dart';
import '../../data/auth_repository.dart';
import 'auth_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();

    return StreamBuilder(
      stream: auth.utilisateurCourant,
      builder: (context, snapshot) {
        // Le temps que Firebase verifie s'il y a une session en cours.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // snapshot.hasData = un utilisateur est connecte.
        if (snapshot.hasData) {
          return const FilAnnoncesPage();
        }

        return const AuthPage();
      },
    );
  }
}
