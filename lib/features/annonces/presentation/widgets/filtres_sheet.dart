// ============================================================
// PANNEAU DE FILTRES (style leboncoin).
// S'ouvre par le bas et laisse choisir : jeu, rôle, plateforme,
// micro, âge. Par défaut tout est sur "Tous" (aucun filtre).
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/jeux.dart';
import '../../../../core/theme/app_theme.dart';

// Contient les filtres choisis par l'utilisateur.
class Filtres {
  String jeu;
  String role;
  String plateforme;
  String micro; // 'Peu importe' | 'Avec micro' | 'Sans micro'
  String age; // 'Tous' | '16+' | '18+' | '21+'
  // 'Ouvertes seulement' par defaut : on ne veut pas rejoindre une
  // equipe deja complete sans le savoir.
  String statut; // 'Ouvertes seulement' | 'Tous' | Ouverte | Complete | Fermee

  Filtres({
    this.jeu = 'Tous',
    this.role = 'Tous',
    this.plateforme = 'Tous',
    this.micro = 'Peu importe',
    this.age = 'Tous',
    this.statut = 'Ouvertes seulement',
  });

  // Une copie (pour modifier sans toucher l'original tant qu'on n'a pas validé).
  Filtres copie() => Filtres(
        jeu: jeu,
        role: role,
        plateforme: plateforme,
        micro: micro,
        age: age,
        statut: statut,
      );

  // Combien de filtres sont actifs (pour l'afficher sur le bouton).
  int get nbActifs => [
        jeu != 'Tous',
        role != 'Tous',
        plateforme != 'Tous',
        micro != 'Peu importe',
        age != 'Tous',
        statut != 'Ouvertes seulement',
      ].where((actif) => actif).length;
}

// Ouvre le panneau et renvoie les filtres choisis (null si l'utilisateur ferme).
Future<Filtres?> ouvrirFiltres(BuildContext context, Filtres actuels) {
  return showModalBottomSheet<Filtres>(
    context: context,
    backgroundColor: context.couleurs.surface,
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
  // On repart de la liste partagee des jeux, en ajoutant "Tous" devant.
  final _jeux = ['Tous', ...nomsJeux];
  final _plateformes = ['Tous', 'PC', 'PS5', 'Xbox', 'Switch'];
  final _micros = ['Peu importe', 'Avec micro', 'Sans micro'];
  final _ages = ['Tous', '16+', '18+', '21+'];
  final _statuts = ['Ouvertes seulement', 'Tous', 'Complète', 'Fermée'];

  // Les roles du jeu selectionne, ou null si aucun jeu n'est choisi.
  List<String>? get _rolesDuJeu =>
      f.jeu == 'Tous' ? null : jeuParNom(f.jeu)?.roles;

  // Affiche a la place des roles quand aucun jeu n'est selectionne.
  Widget _messageChoisirJeu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôle',
          style: TextStyle(
            color: context.couleurs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline,
                size: 16, color: context.couleurs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Choisis un jeu pour voir ses rôles',
              style: TextStyle(
                color: context.couleurs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }

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
                  color: context.couleurs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Filtres',
              style: TextStyle(color: context.couleurs.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _section('Jeu', _jeux, f.jeu, (v) {
              setState(() {
                f.jeu = v;
                // Les roles dependent du jeu : si on change de jeu,
                // l'ancien role choisi n'a plus de sens.
                f.role = 'Tous';
              });
            }),

            // Les roles ne s'affichent qu'une fois un jeu choisi,
            // car chaque jeu a ses propres roles.
            if (_rolesDuJeu != null)
              _section('Rôle', ['Tous', ..._rolesDuJeu!], f.role,
                  (v) => setState(() => f.role = v))
            else
              _messageChoisirJeu(context),

            _section('Plateforme', _plateformes, f.plateforme, (v) => setState(() => f.plateforme = v)),
            _section('Micro', _micros, f.micro, (v) => setState(() => f.micro = v)),
            _section('Âge', _ages, f.age, (v) => setState(() => f.age = v)),
            _section('État', _statuts, f.statut, (v) => setState(() => f.statut = v)),

            const SizedBox(height: 12),

            // Boutons Réinitialiser / Appliquer.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    // Réinitialiser = renvoyer des filtres vides (tout sur "Tous").
                    onPressed: () => Navigator.pop(context, Filtres()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.couleurs.onSurfaceVariant,
                      side: BorderSide(color: context.couleurs.outlineVariant),
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
                      backgroundColor: context.couleurs.primary,
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
          style: TextStyle(color: context.couleurs.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
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
                color: actif ? Colors.white : context.couleurs.onSurfaceVariant,
                fontSize: 13,
              ),
              backgroundColor: context.couleurs.surfaceContainerHighest,
              selectedColor: context.couleurs.primary,
              side: BorderSide(color: context.couleurs.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
