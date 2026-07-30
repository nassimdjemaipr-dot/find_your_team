// ============================================================
// LISTE DES JEUX de l'application.
// Reference partagee : les filtres, la vue par jeu et le formulaire
// de creation d'annonce utilisent tous cette meme liste.
// Pour ajouter un jeu, il suffit de l'ajouter ici.
// ============================================================
import 'package:flutter/material.dart';

class Jeu {
  final String nom;
  final IconData icone;
  // Image de fond de la carte du jeu.
  final String image;
  // Couleurs utilisees pour l'entete et le voile pose sur l'image,
  // pour que le texte reste lisible.
  final Color couleurDebut;
  final Color couleurFin;

  const Jeu({
    required this.nom,
    required this.icone,
    required this.image,
    required this.couleurDebut,
    required this.couleurFin,
  });
}

const List<Jeu> jeux = [
  Jeu(
    nom: 'Valorant',
    icone: Icons.my_location,
    image: 'assets/images/jeux/valorant.webp',
    couleurDebut: Color(0xFFFF4655),
    couleurFin: Color(0xFF8B1E2B),
  ),
  Jeu(
    nom: 'League of Legends',
    icone: Icons.shield,
    image: 'assets/images/jeux/lol.jpg',
    couleurDebut: Color(0xFFC8AA6E),
    couleurFin: Color(0xFF1E3A5F),
  ),
  Jeu(
    nom: 'CS:GO',
    icone: Icons.gps_fixed,
    image: 'assets/images/jeux/csgo.jpg',
    couleurDebut: Color(0xFFF0A500),
    couleurFin: Color(0xFF5C4200),
  ),
  Jeu(
    nom: 'Rocket League',
    icone: Icons.sports_soccer,
    image: 'assets/images/jeux/rocket_league.jpg',
    couleurDebut: Color(0xFF2A8FDB),
    couleurFin: Color(0xFF0B2E6B),
  ),
];

// Les noms seuls (pratique pour les listes deroulantes et les filtres).
List<String> get nomsJeux => jeux.map((j) => j.nom).toList();
