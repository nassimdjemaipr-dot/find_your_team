// Tests unitaires du projet.
//
// On ne teste plus l'ecran du fil : depuis qu'il lit Firestore en
// temps reel, il faudrait initialiser Firebase, ce qui n'a pas de sens
// dans un test. On teste donc la logique pure, qui ne depend de rien :
// le modele Annonce et le compteur de filtres.
import 'package:flutter_test/flutter_test.dart';

import 'package:find_your_team/core/jeux.dart';
import 'package:find_your_team/features/annonces/models/annonce.dart';
import 'package:find_your_team/features/annonces/presentation/widgets/filtres_sheet.dart';

void main() {
  group('Modele Annonce', () {
    test('fromMap lit correctement les donnees Firestore', () {
      final annonce = Annonce.fromMap('abc123', {
        'userId': 'uid-1',
        'pseudo': 'NoScopeKing',
        'age': 19,
        'jeu': 'Valorant',
        'roles': ['Duelliste', 'Initiateur'],
        'micro': true,
        'nombreJoueurs': 2,
        'dateCreation': '2026-07-30T18:30:00.000',
      });

      expect(annonce.id, 'abc123');
      expect(annonce.userId, 'uid-1');
      expect(annonce.pseudo, 'NoScopeKing');
      expect(annonce.roles, ['Duelliste', 'Initiateur']);
      expect(annonce.micro, isTrue);
    });

    test('fromMap utilise des valeurs par defaut si un champ manque', () {
      final annonce = Annonce.fromMap('vide', {});

      expect(annonce.pseudo, '');
      expect(annonce.age, 0);
      expect(annonce.roles, isEmpty);
      expect(annonce.micro, isFalse);
      expect(annonce.nombreJoueurs, 1);
    });

    test('toMap puis fromMap redonne la meme annonce', () {
      final depart = Annonce(
        id: '1',
        userId: 'uid-1',
        pseudo: 'Test',
        age: 20,
        jeu: 'CS:GO',
        rangMin: 'Argent',
        rangMax: 'Or',
        plateforme: 'PC',
        roles: ['AWPer'],
        micro: true,
        pseudoJeu: 'test_cs',
        discord: 'test#0001',
        nombreJoueurs: 3,
        dureeMinutes: 90,
        description: 'Test',
        dateCreation: DateTime(2026, 7, 30),
      );

      final retour = Annonce.fromMap('1', depart.toMap());

      expect(retour.jeu, depart.jeu);
      expect(retour.userId, depart.userId);
      expect(retour.roles, depart.roles);
      expect(retour.dateCreation, depart.dateCreation);
    });
  });

  group('Filtres', () {
    test('aucun filtre actif par defaut', () {
      expect(Filtres().nbActifs, 0);
    });

    test('compte le nombre de filtres actifs', () {
      final f = Filtres(jeu: 'Valorant', micro: 'Avec micro');
      expect(f.nbActifs, 2);
    });

    test('la copie est independante de l\'original', () {
      final original = Filtres(jeu: 'Valorant');
      final copie = original.copie()..jeu = 'CS:GO';

      expect(original.jeu, 'Valorant');
      expect(copie.jeu, 'CS:GO');
    });
  });

  group('Jeux', () {
    test('chaque jeu a des roles', () {
      for (final jeu in jeux) {
        expect(jeu.roles, isNotEmpty, reason: '${jeu.nom} n\'a aucun role');
      }
    });

    test('jeuParNom retrouve un jeu et ses roles', () {
      expect(jeuParNom('Valorant')?.roles, contains('Duelliste'));
      expect(jeuParNom('League of Legends')?.roles, contains('Jungle'));
    });

    test('jeuParNom renvoie null pour un jeu inconnu', () {
      expect(jeuParNom('Minecraft'), isNull);
    });
  });
}
