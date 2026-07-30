// ============================================================
// ÉCRAN Fil d'annonces (tâche #7).
// Affiche toutes les annonces en temps reel (StreamBuilder sur
// Firestore) + une recherche + un bouton Filtres (jeu, role,
// plateforme, micro, age) facon leboncoin.
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/annonce_repository.dart';
import '../../models/annonce.dart';
import '../widgets/annonce_card.dart';
import '../widgets/filtres_sheet.dart';

class FilAnnoncesPage extends StatefulWidget {
  const FilAnnoncesPage({super.key});

  @override
  State<FilAnnoncesPage> createState() => _FilAnnoncesPageState();
}

class _FilAnnoncesPageState extends State<FilAnnoncesPage> {
  // Le texte tape dans la barre de recherche.
  String _recherche = '';

  // Les filtres choisis (par defaut : tout sur "Tous").
  Filtres _filtres = Filtres();

  final _repository = AnnonceRepository();

  // Transforme "18+" en 18, etc. (0 = pas de filtre d'age).
  int _ageMinimum(String choix) {
    switch (choix) {
      case '16+':
        return 16;
      case '18+':
        return 18;
      case '21+':
        return 21;
      default:
        return 0;
    }
  }

  // Applique la recherche + tous les filtres sur les annonces recues.
  List<Annonce> _appliquerFiltres(List<Annonce> annonces) {
    return annonces.where((a) {
      // 1. Recherche (pseudo ou jeu), insensible a la casse.
      final texte = _recherche.toLowerCase();
      final okRecherche = texte.isEmpty ||
          a.pseudo.toLowerCase().contains(texte) ||
          a.jeu.toLowerCase().contains(texte);

      // 2. Les filtres du panneau.
      final okJeu = _filtres.jeu == 'Tous' || a.jeu == _filtres.jeu;
      final okRole = _filtres.role == 'Tous' || a.roles.contains(_filtres.role);
      final okPlateforme =
          _filtres.plateforme == 'Tous' || a.plateforme == _filtres.plateforme;
      final okMicro = _filtres.micro == 'Peu importe' ||
          (_filtres.micro == 'Avec micro' ? a.micro : !a.micro);
      final okAge = a.age >= _ageMinimum(_filtres.age);

      return okRecherche && okJeu && okRole && okPlateforme && okMicro && okAge;
    }).toList();
  }

  // Ouvre le panneau de filtres et recupere le choix de l'utilisateur.
  Future<void> _ouvrirFiltres() async {
    final resultat = await ouvrirFiltres(context, _filtres);
    if (resultat != null) {
      setState(() => _filtres = resultat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nbFiltres = _filtres.nbActifs;

    // Pas de Scaffold ici : cette page est un onglet de la HomePage,
    // c'est elle qui porte l'AppBar, la barre du bas et le bouton flottant.
    return Column(
      children: [
        // --- Barre de recherche ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: TextField(
            onChanged: (valeur) => setState(() => _recherche = valeur),
            decoration: const InputDecoration(
              hintText: 'Rechercher un joueur, un jeu...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),

        // --- Ligne : bouton Filtres + nombre de resultats ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _ouvrirFiltres,
                icon: const Icon(Icons.tune, size: 18),
                label: Text(nbFiltres == 0 ? 'Filtres' : 'Filtres ($nbFiltres)'),
                style: OutlinedButton.styleFrom(
                  // Le bouton devient violet quand des filtres sont actifs.
                  foregroundColor: nbFiltres == 0
                      ? context.couleurs.onSurfaceVariant
                      : Colors.white,
                  backgroundColor: nbFiltres == 0
                      ? context.couleurs.surfaceContainerHighest
                      : context.couleurs.primary,
                  side: BorderSide(
                    color: nbFiltres == 0
                        ? context.couleurs.outlineVariant
                        : context.couleurs.primary,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Spacer(),

              // Le compteur suit le flux temps reel, filtres compris.
              StreamBuilder<List<Annonce>>(
                stream: _repository.annoncesStream(),
                builder: (context, snapshot) {
                  final nb = _appliquerFiltres(snapshot.data ?? []).length;
                  return Text(
                    '$nb résultat${nb > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: context.couleurs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // --- La liste des annonces, en temps reel ---
        Expanded(
          child: StreamBuilder<List<Annonce>>(
            stream: _repository.annoncesStream(),
            builder: (context, snapshot) {
              // En attente de la premiere reponse de Firestore.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur : ${snapshot.error}',
                    style: TextStyle(color: context.couleurs.onSurfaceVariant),
                  ),
                );
              }

              final annonces = _appliquerFiltres(snapshot.data ?? []);

              return annonces.isEmpty
                  ? _EtatVide()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: annonces.length,
                      itemBuilder: (context, index) {
                        return AnnonceCard(annonce: annonces[index]);
                      },
                    );
            },
          ),
        ),
      ],
    );
  }
}

// Message affiche quand aucune annonce ne correspond.
class _EtatVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 60, color: context.couleurs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Aucune annonce trouvée',
            style: TextStyle(color: context.couleurs.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
