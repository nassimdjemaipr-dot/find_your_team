// ============================================================
// ÉCRAN des annonces d'UN jeu precis.
// On y arrive en cliquant sur une carte de l'onglet "Par jeu".
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/jeux.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/annonce_repository.dart';
import '../../models/annonce.dart';
import '../widgets/annonce_card.dart';

class AnnoncesJeuPage extends StatelessWidget {
  final Jeu jeu;

  const AnnoncesJeuPage({super.key, required this.jeu});

  @override
  Widget build(BuildContext context) {
    final repository = AnnonceRepository();

    // Temps reel : on ecoute Firestore et on ne garde que les
    // annonces de ce jeu.
    return StreamBuilder<List<Annonce>>(
      stream: repository.annoncesStream(),
      builder: (context, snapshot) {
        final annonces =
            (snapshot.data ?? []).where((a) => a.jeu == jeu.nom).toList();

        // Vrai tant que Firestore n'a pas encore repondu.
        final chargement = snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
          // En-tete colore aux couleurs du jeu, qui se replie au scroll.
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: jeu.couleurFin,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                jeu.nom,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // L'image du jeu, avec repli sur le degrade si absente.
                  Image.asset(
                    jeu.image,
                    fit: BoxFit.cover,
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
                  // Voile sombre pour garder le titre lisible.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

              // Le nombre d'annonces trouvees.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    '${annonces.length} annonce${annonces.length > 1 ? 's' : ''} en cours',
                    style: TextStyle(
                        color: context.couleurs.onSurfaceVariant, fontSize: 14),
                  ),
                ),
              ),

              // Chargement, puis la liste ou un message si c'est vide.
              if (chargement)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (annonces.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox,
                            size: 56, color: context.couleurs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune annonce pour ce jeu',
                          style: TextStyle(
                              color: context.couleurs.onSurfaceVariant,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: annonces.length,
                    itemBuilder: (context, index) =>
                        AnnonceCard(annonce: annonces[index]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
