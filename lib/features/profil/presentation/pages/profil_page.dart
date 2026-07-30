// ============================================================
// ONGLET Profil (version de base).
// Affiche les infos du compte connecte et la deconnexion.
// La gestion de "mes annonces" viendra avec la tache #10.
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/stockage/preferences_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../annonces/presentation/pages/mes_favoris_page.dart';

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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.couleurs.primary, const Color(0xFF5F4FF5)],
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
                style: TextStyle(
                  color: context.couleurs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(color: context.couleurs.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- Choix du theme (enregistre en local avec Hive) ---
        // Material (et pas Container) : le SwitchListTile a besoin d'un
        // Material parent pour dessiner son fond et son effet de clic.
        Material(
          color: context.couleurs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.couleurs.outlineVariant),
            ),
            child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: PreferencesService.themeSombre,
            // Un seul appel : Hive enregistre le choix, et l'application
            // se repeint toute seule (elle ecoute la box dans main.dart).
            onChanged: (valeur) => PreferencesService.setThemeSombre(valeur),
            activeThumbColor: context.couleurs.primary,
            secondary: Icon(
              PreferencesService.themeSombre
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: context.couleurs.primary,
            ),
            title: Text(
              'Theme sombre',
              style: TextStyle(
                color: context.couleurs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              PreferencesService.themeSombre ? 'Active' : 'Desactive',
              style: TextStyle(
                color: context.couleurs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // --- Emplacement pour "mes annonces" (tache #10) ---
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.couleurs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.couleurs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.article_outlined, color: context.couleurs.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mes annonces arrivent bientot',
                  style: TextStyle(color: context.couleurs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MesFavorisPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.couleurs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.couleurs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.star_outlined, color: context.couleurs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mes favoris',
                    style: TextStyle(color: context.couleurs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
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