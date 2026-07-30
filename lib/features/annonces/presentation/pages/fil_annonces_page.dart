// ============================================================
// ÉCRAN Fil d'annonces (tâche #7).
// Affiche la liste des annonces + une recherche + un bouton Filtres
// (jeu, rôle, plateforme, micro, âge) façon leboncoin.
//
// Pour l'instant on lit les DONNÉES FACTICES. Plus tard on remplacera
// par un StreamBuilder sur AnnonceRepository.annoncesStream() (Firestore).
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/annonce_repository.dart';
import '../../models/annonce.dart';
import '../widgets/annonce_card.dart';
import '../widgets/filtres_sheet.dart';
import 'creer_annonce_page.dart';

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
      final okPlateforme = _filtres.plateforme == 'Tous' || a.plateforme == _filtres.plateforme;
      final okMicro = _filtres.micro == 'Peu importe' ||
          (_filtres.micro == 'Avec micro' ? a.micro : !a.micro);
      final okAge = a.age >= _ageMinimum(_filtres.age);

      return okRecherche && okJeu && okRole && okPlateforme && okMicro && okAge;
    }).toList();
  }

  // Ouvre le panneau de filtres et récupère le choix de l'utilisateur.
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
    // c'est elle qui porte l'AppBar, la TabBar et le bouton flottant.
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

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _ouvrirFiltres,
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(nbFiltres == 0 ? 'Filtres' : 'Filtres ($nbFiltres)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: nbFiltres == 0 ? AppTheme.texteDoux : Colors.white,
                    backgroundColor: nbFiltres == 0 ? AppTheme.surface : AppTheme.violet,
                    side: BorderSide(
                      color: nbFiltres == 0 ? AppTheme.bordure : AppTheme.violet,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Spacer(),
                StreamBuilder<List<Annonce>>(
                  stream: _repository.annoncesStream(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    final filtrees = _appliquerFiltres(snapshot.data ?? []);
                    return Text(
                      '${filtrees.length} résultat${filtrees.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: AppTheme.texteDoux, fontSize: 13),
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
                  return Center(child: Text('Erreur : ${snapshot.error}'));
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
  }
}

// Message affiché quand aucune annonce ne correspond.
class _EtatVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off, size: 60, color: AppTheme.texteDoux),
          SizedBox(height: 12),
          Text(
            'Aucune annonce trouvée',
            style: TextStyle(color: AppTheme.texteDoux, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
