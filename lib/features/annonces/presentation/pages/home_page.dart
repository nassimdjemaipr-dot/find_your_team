// ============================================================
// PAGE PRINCIPALE de l'application.
// Porte la barre de navigation du bas (3 onglets) :
//   1. Par jeu   -> les jeux, clic pour voir leurs annonces
//   2. Annonces  -> le fil complet avec recherche et filtres
//   3. Profil    -> le compte connecte
//
// StatefulWidget car l'onglet selectionne change l'affichage.
// On utilise IndexedStack (et pas un simple switch) pour garder
// l'etat de chaque onglet : la recherche et les filtres du fil
// ne sont pas perdus quand on change d'onglet puis on revient.
// ============================================================
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profil/presentation/pages/profil_page.dart';
import 'fil_annonces_page.dart';
import 'jeux_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _onglet = 0;

  // Le titre affiche en haut change selon l'onglet.
  static const _titres = ['Find Your Team', 'Toutes les annonces', 'Mon profil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titres[_onglet],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: IndexedStack(
        index: _onglet,
        children: const [
          JeuxPage(),
          FilAnnoncesPage(),
          ProfilPage(),
        ],
      ),

      // Bouton de creation d'annonce, cache sur l'onglet Profil.
      floatingActionButton: _onglet == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                // TODO : ouvrir l'ecran Creer une annonce (tache #9).
              },
              backgroundColor: AppTheme.violet,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Annonce'),
            ),

      // --- La barre de navigation du bas ---
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.bordure)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: AppTheme.violet.withValues(alpha: 0.2),
            labelTextStyle: WidgetStateProperty.resolveWith((etats) {
              final actif = etats.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                color: actif ? AppTheme.violet : AppTheme.texteDoux,
                fontWeight: actif ? FontWeight.bold : FontWeight.normal,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((etats) {
              final actif = etats.contains(WidgetState.selected);
              return IconThemeData(
                color: actif ? AppTheme.violet : AppTheme.texteDoux,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _onglet,
            onDestinationSelected: (i) => setState(() => _onglet = i),
            height: 68,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.sports_esports_outlined),
                selectedIcon: Icon(Icons.sports_esports),
                label: 'Par jeu',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'Annonces',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
