// ============================================================
// ONGLET Profil (version de base).
// Affiche les infos du compte connecte et la deconnexion.
// La gestion de "mes annonces" viendra avec la tache #10.
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_repository.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();
    final user = auth.utilisateur;

    // displayName = le pseudo choisi a l'inscription.
    final pseudo = user?.displayName ?? 'Joueur';
    final email = user?.email ?? '';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),

        // --- Avatar + pseudo ---
        Center(
          child: Column(
            children: [
              Container(
                height: 88,
                width: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.violet, Color(0xFF5F4FF5)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  pseudo.isNotEmpty ? pseudo[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                pseudo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(color: AppTheme.texteDoux, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- Emplacement pour "mes annonces" (tache #10) ---
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.bordure),
          ),
          child: const Row(
            children: [
              Icon(Icons.article_outlined, color: AppTheme.texteDoux),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mes annonces arrivent bientot',
                  style: TextStyle(color: AppTheme.texteDoux),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- Deconnexion ---
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => auth.deconnexion(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Se deconnecter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade300,
              side: BorderSide(color: Colors.red.shade300.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}