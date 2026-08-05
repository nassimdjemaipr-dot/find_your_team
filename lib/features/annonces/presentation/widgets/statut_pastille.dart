// ============================================================
// PASTILLE DE STATUT.
// Petite etiquette coloree affichee sur une annonce :
//   vert   = Ouverte  (on cherche encore)
//   orange = Complete (l'equipe est faite)
//   rouge  = Fermee   (termine)
// ============================================================
import 'package:flutter/material.dart';
import '../../models/annonce.dart';

// Couleur associee a chaque statut.
Color couleurStatut(String statut) {
  switch (statut) {
    case StatutAnnonce.complete:
      return const Color(0xFFF0A500);
    case StatutAnnonce.fermee:
      return const Color(0xFFE5484D);
    default:
      return const Color(0xFF30A46C);
  }
}

// Libelle affiche a l'utilisateur (avec les accents).
String libelleStatut(String statut) {
  switch (statut) {
    case StatutAnnonce.complete:
      return 'Complète';
    case StatutAnnonce.fermee:
      return 'Fermée';
    default:
      return 'Ouverte';
  }
}

class StatutPastille extends StatelessWidget {
  final String statut;
  final bool compact;

  const StatutPastille({
    super.key,
    required this.statut,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = couleurStatut(statut);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Le petit rond de couleur.
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            libelleStatut(statut),
            style: TextStyle(
              color: couleur,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
