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
  String _recherche = '';
  Filtres _filtres = Filtres();
  final _repository = AnnonceRepository();

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

  List<Annonce> _appliquerFiltres(List<Annonce> annonces) {
    return annonces.where((a) {
      final texte = _recherche.toLowerCase();
      final okRecherche = texte.isEmpty ||
          a.pseudo.toLowerCase().contains(texte) ||
          a.jeu.toLowerCase().contains(texte);

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

  Future<void> _ouvrirFiltres() async {
    final resultat = await ouvrirFiltres(context, _filtres);
    if (resultat != null) {
      setState(() => _filtres = resultat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nbFiltres = _filtres.nbActifs;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
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

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _ouvrirFiltres,
                icon: const Icon(Icons.tune, size: 18),
                label: Text(nbFiltres == 0 ? 'Filtres' : 'Filtres ($nbFiltres)'),
                style: OutlinedButton.styleFrom(
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

        Expanded(
          child: StreamBuilder<List<Annonce>>(
            stream: _repository.annoncesStream(),
            builder: (context, snapshot) {
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

              if (annonces.isEmpty) {
                return _EtatVide();
              }

              if (isMobile) {
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: annonces.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: AnnonceCard(annonce: annonces[index]),
                    );
                  },
                );
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: annonces.length,
                  itemBuilder: (context, index) {
                    return AnnonceCard(annonce: annonces[index]);
                  },
                );
              }
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
