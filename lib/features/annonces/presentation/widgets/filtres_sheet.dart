// ============================================================
// PANNEAU DE FILTRES (style leboncoin).
// S'ouvre par le bas et laisse choisir : jeu, rôle, plateforme,
// micro, âge. Par défaut tout est sur "Tous" (aucun filtre).
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Contient les filtres choisis par l'utilisateur.
class Filtres {
  String jeu;
  String role;
  String plateforme;
  String micro; // 'Peu importe' | 'Avec micro' | 'Sans micro'
  String age; // 'Tous' | '16+' | '18+' | '21+'

  Filtres({
    this.jeu = 'Tous',
    this.role = 'Tous',
    this.plateforme = 'Tous',
    this.micro = 'Peu importe',
    this.age = 'Tous',
  });

  // Une copie (pour modifier sans toucher l'original tant qu'on n'a pas validé).
  Filtres copie() => Filtres(
        jeu: jeu,
        role: role,
        plateforme: plateforme,
        micro: micro,
        age: age,
      );

  // Combien de filtres sont actifs (pour l'afficher sur le bouton).
  int get nbActifs => [
        jeu != 'Tous',
        role != 'Tous',
        plateforme != 'Tous',
        micro != 'Peu importe',
        age != 'Tous',
      ].where((actif) => actif).length;
}

// Ouvre le panneau et renvoie les filtres choisis (null si l'utilisateur ferme).
Future<Filtres?> ouvrirFiltres(BuildContext context, Filtres actuels) {
  return showModalBottomSheet<Filtres>(
    context: context,
    backgroundColor: AppTheme.fond,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _FiltresSheet(actuels: actuels.copie()),
  );
}

class _FiltresSheet extends StatefulWidget {
  final Filtres actuels;
  const _FiltresSheet({required this.actuels});

  @override
  State<_FiltresSheet> createState() => _FiltresSheetState();
}

class _FiltresSheetState extends State<_FiltresSheet> {
  late Filtres f = widget.actuels;

  // Les choix possibles pour chaque filtre.
  final _jeux = ['Tous', 'Valorant', 'League of Legends', 'Counter-Strike 2', 'Rocket League'];
  final _roles = ['Tous', 'Duelliste', 'Initiateur', 'Support', 'Entry', 'AWP', '2v2'];
  final _plateformes = ['Tous', 'PC', 'PS5', 'Xbox', 'Switch'];
  final _micros = ['Peu importe', 'Avec micro', 'Sans micro'];
  final _ages = ['Tous', '16+', '18+', '21+'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Petite poignée en haut du panneau.
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.bordure,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Filtres',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _section('Jeu', _jeux, f.jeu, (v) => setState(() => f.jeu = v)),
            _section('Rôle', _roles, f.role, (v) => setState(() => f.role = v)),
            _section('Plateforme', _plateformes, f.plateforme, (v) => setState(() => f.plateforme = v)),
            _section('Micro', _micros, f.micro, (v) => setState(() => f.micro = v)),
            _section('Âge', _ages, f.age, (v) => setState(() => f.age = v)),

            const SizedBox(height: 12),

            // Boutons Réinitialiser / Appliquer.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    // Réinitialiser = renvoyer des filtres vides (tout sur "Tous").
                    onPressed: () => Navigator.pop(context, Filtres()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.texteDoux,
                      side: const BorderSide(color: AppTheme.bordure),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, f),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.violet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Une section de filtre : un titre + des chips à choisir.
  Widget _section(String titre, List<String> options, String choisi, ValueChanged<String> onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final actif = option == choisi;
            return ChoiceChip(
              label: Text(option),
              selected: actif,
              onSelected: (_) => onPick(option),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: actif ? Colors.white : AppTheme.texteDoux,
                fontSize: 13,
              ),
              backgroundColor: AppTheme.surface,
              selectedColor: AppTheme.violet,
              side: const BorderSide(color: AppTheme.bordure),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
