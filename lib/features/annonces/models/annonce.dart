// ============================================================
// MODÈLE Annonce (POO)
// Représente une annonce postée par un joueur qui cherche une équipe.
//
// Note : on utilise fromMap / toMap (et pas fromFirestore directement)
// pour NE PAS dépendre de cloud_firestore ici. Comme ça l'UI peut
// utiliser ce modèle sans Firebase. Côté repository, Melvyn fera :
//   Annonce.fromMap(doc.id, doc.data())
// ============================================================
class Annonce {
  final String id;
  final String pseudo; // pseudo du compte (l'auteur de l'annonce)
  final int age; // âge du joueur
  final String jeu; // ex : Valorant, League of Legends...
  final String rangMin; // rang minimum recherché
  final String rangMax; // rang maximum recherché
  final String plateforme; // PC, PS5, Xbox, Switch...
  final List<String> roles; // rôles recherchés (on peut en demander plusieurs)
  final bool micro; // le micro est-il obligatoire ?
  final String pseudoJeu; // pseudo utilisé DANS le jeu
  final String discord; // pour contacter le joueur
  final int nombreJoueurs; // nombre de joueurs recherchés
  final int dureeMinutes; // durée de validité de l'annonce (en minutes)
  final String description;
  final DateTime dateCreation;

  Annonce({
    required this.id,
    required this.pseudo,
    required this.age,
    required this.jeu,
    required this.rangMin,
    required this.rangMax,
    required this.plateforme,
    required this.roles,
    required this.micro,
    required this.pseudoJeu,
    required this.discord,
    required this.nombreJoueurs,
    required this.dureeMinutes,
    required this.description,
    required this.dateCreation,
  });

  // Construit une Annonce à partir d'une Map (ex : les données Firestore).
  factory Annonce.fromMap(String id, Map<String, dynamic> data) {
    return Annonce(
      id: id,
      pseudo: data['pseudo'] ?? '',
      age: data['age'] ?? 0,
      jeu: data['jeu'] ?? '',
      rangMin: data['rangMin'] ?? '',
      rangMax: data['rangMax'] ?? '',
      plateforme: data['plateforme'] ?? '',
      // Firestore renvoie une List<dynamic>, on la convertit en List<String>.
      roles: List<String>.from(data['roles'] ?? const []),
      micro: data['micro'] ?? false,
      pseudoJeu: data['pseudoJeu'] ?? '',
      discord: data['discord'] ?? '',
      nombreJoueurs: data['nombreJoueurs'] ?? 1,
      dureeMinutes: data['dureeMinutes'] ?? 60,
      description: data['description'] ?? '',
      // Si la date manque, on met "maintenant" par défaut.
      dateCreation: DateTime.tryParse(data['dateCreation'] ?? '') ?? DateTime.now(),
    );
  }

  // Transforme l'Annonce en Map (pour l'enregistrer dans Firestore).
  Map<String, dynamic> toMap() {
    return {
      'pseudo': pseudo,
      'age': age,
      'jeu': jeu,
      'rangMin': rangMin,
      'rangMax': rangMax,
      'plateforme': plateforme,
      'roles': roles,
      'micro': micro,
      'pseudoJeu': pseudoJeu,
      'discord': discord,
      'nombreJoueurs': nombreJoueurs,
      'dureeMinutes': dureeMinutes,
      'description': description,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
