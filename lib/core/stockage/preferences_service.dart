// ============================================================
// STOCKAGE LOCAL avec Hive.
// C'est le 2e stockage de l'application (le 1er etant Firestore,
// qui est distant). Hive est une petite base de donnees locale :
// les donnees restent sur le telephone, meme sans internet.
//
// Ici on s'en sert pour retenir le theme choisi par l'utilisateur.
// ============================================================
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class PreferencesService {
  // Nom de la "box" : c'est l'equivalent d'une table.
  static const _nomBox = 'preferences';

  // Nom de la cle dans la box.
  static const _cleThemeSombre = 'themeSombre';

  static late Box _box;

  // A appeler UNE FOIS au demarrage, avant runApp().
  static Future<void> initialiser() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_nomBox);
  }

  // Lit le theme enregistre. Par defaut : sombre (le theme d'origine).
  static bool get themeSombre =>
      _box.get(_cleThemeSombre, defaultValue: true) as bool;

  // Enregistre le choix de l'utilisateur sur le telephone.
  static Future<void> setThemeSombre(bool sombre) =>
      _box.put(_cleThemeSombre, sombre);

  // Permet a l'interface de se reconstruire automatiquement
  // des que la valeur change (utilise par ValueListenableBuilder).
  static ValueListenable<Box> get ecouteur =>
      _box.listenable(keys: [_cleThemeSombre]);
}
