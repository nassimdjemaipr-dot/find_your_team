// ============================================================
// STOCKAGE LOCAL des informations du joueur (Hive).
//
// Le formulaire de creation d'annonce demande une dizaine de champs,
// mais plusieurs ne changent jamais pour un meme joueur : son age,
// sa plateforme, son pseudo en jeu, son Discord.
//
// On les retient donc en local apres chaque publication, et on
// pre-remplit le formulaire la fois suivante. Le joueur reste
// evidemment libre de les modifier.
//
// C'est le 3e usage de Hive dans l'application, apres le theme
// et les favoris.
// ============================================================
import 'package:hive_ce_flutter/hive_flutter.dart';

class ProfilJoueurService {
  static const _nomBox = 'profilJoueur';

  static const _cleAge = 'age';
  static const _clePlateforme = 'plateforme';
  static const _clePseudoJeu = 'pseudoJeu';
  static const _cleDiscord = 'discord';

  static late Box _box;

  // A appeler UNE FOIS au demarrage, avant runApp().
  static Future<void> initialiser() async {
    _box = await Hive.openBox(_nomBox);
  }

  // --- Lecture (chaine vide si rien n'a encore ete enregistre) ---
  static String get age => _box.get(_cleAge, defaultValue: '') as String;
  static String get plateforme =>
      _box.get(_clePlateforme, defaultValue: '') as String;
  static String get pseudoJeu =>
      _box.get(_clePseudoJeu, defaultValue: '') as String;
  static String get discord =>
      _box.get(_cleDiscord, defaultValue: '') as String;

  // Vrai si on a deja enregistre quelque chose : sert a prevenir
  // l'utilisateur que le formulaire a ete pre-rempli.
  static bool get aDesInfos =>
      age.isNotEmpty ||
      plateforme.isNotEmpty ||
      pseudoJeu.isNotEmpty ||
      discord.isNotEmpty;

  // --- Ecriture ---
  // Appelee apres la publication d'une annonce.
  static Future<void> enregistrer({
    required String age,
    required String plateforme,
    required String pseudoJeu,
    required String discord,
  }) async {
    await _box.putAll({
      _cleAge: age,
      _clePlateforme: plateforme,
      _clePseudoJeu: pseudoJeu,
      _cleDiscord: discord,
    });
  }

  // Permet a l'utilisateur d'effacer ses informations enregistrees.
  static Future<void> effacer() => _box.clear();
}
