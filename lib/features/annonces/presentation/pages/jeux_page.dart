// ============================================================
// ONGLET "Par jeu".
// Affiche une grille de cartes, une par jeu, avec le nombre
// d'annonces en cours. Un clic ouvre les annonces de ce jeu.
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/jeux.dart';
import '../../data/annonce_repository.dart';
import '../../models/annonce.dart';
import 'annonces_jeu_page.dart';

class JeuxPage extends StatelessWidget {
  const JeuxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AnnonceRepository();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return StreamBuilder<List<Annonce>>(
      stream: repository.annoncesStream(),
      builder: (context, snapshot) {
        final annonces = snapshot.data ?? [];

        if (isMobile) {
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: jeux.length,
            itemBuilder: (context, index) {
              final jeu = jeux[index];
              final nb = annonces.where((a) => a.jeu == jeu.nom).length;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: _CarteJeu(jeu: jeu, nbAnnonces: nb),
              );
            },
          );
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemCount: jeux.length,
            itemBuilder: (context, index) {
              final jeu = jeux[index];
              final nb = annonces.where((a) => a.jeu == jeu.nom).length;

              return _CarteJeu(jeu: jeu, nbAnnonces: nb);
            },
          );
        }
      },
    );
  }
}

class _CarteJeu extends StatelessWidget {
  final Jeu jeu;
  final int nbAnnonces;

  const _CarteJeu({required this.jeu, required this.nbAnnonces});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnnoncesJeuPage(jeu: jeu)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: jeu.couleurDebut.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // ClipRRect pour que l'image respecte les coins arrondis.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. L'image du jeu en fond.
              Image.asset(
                jeu.image,
                fit: BoxFit.cover,
                // Si l'image est absente, on retombe sur le degrade
                // pour que l'app continue de s'afficher correctement.
                errorBuilder: (context, error, stack) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [jeu.couleurDebut, jeu.couleurFin],
                    ),
                  ),
                ),
              ),

              // 2. Un voile sombre du bas vers le haut, pour que
              //    le nom du jeu reste lisible sur n'importe quelle image.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.80),
                    ],
                  ),
                ),
              ),

              // 3. Le contenu par-dessus.
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      jeu.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Pastille avec le nombre d'annonces.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        nbAnnonces == 0
                            ? 'Aucune annonce'
                            : '$nbAnnonces annonce${nbAnnonces > 1 ? 's' : ''}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

