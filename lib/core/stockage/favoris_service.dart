import 'package:hive_ce/hive.dart';

class FavorisService {
  static const _boxName = 'favoris';

  static Future<void> initialiser() async {
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  static Future<void> ajouter(String annonceId) async {
    await _box.put(annonceId, annonceId);
  }

  static Future<void> retirer(String annonceId) async {
    await _box.delete(annonceId);
  }

  static bool isFavori(String annonceId) {
    return _box.containsKey(annonceId);
  }

  static List<String> obtenirTous() {
    return _box.values.toList();
  }

  static Future<void> toggle(String annonceId) async {
    if (isFavori(annonceId)) {
      await retirer(annonceId);
    } else {
      await ajouter(annonceId);
    }
  }
}
