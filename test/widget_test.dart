// Test de base de l'ecran Fil d'annonces.
// On teste la page directement (pas MyApp) car MyApp a besoin
// que Firebase soit initialise, ce qui n'est pas le cas en test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_your_team/features/annonces/presentation/pages/fil_annonces_page.dart';

void main() {
  testWidgets('Le fil affiche la recherche et le bouton Filtres',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FilAnnoncesPage()));

    // La barre de recherche et le bouton de filtres sont bien la.
    expect(find.text('Rechercher un joueur, un jeu...'), findsOneWidget);
    expect(find.text('Filtres'), findsOneWidget);

    // Les annonces factices sont affichees.
    expect(find.text('NoScopeKing'), findsOneWidget);
  });
}
