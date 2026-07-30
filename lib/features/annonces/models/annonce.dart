class Annonce {
  final String id;
  // UID Firebase de l'auteur : relie l'annonce a son createur.
  // Sert pour "mes annonces" et pour les regles de securite Firestore.
  final String userId;
  final String pseudo;
  final int age;
  final String jeu;
  final String rangMin;
  final String rangMax;
  final String plateforme;
  final List<String> roles;
  final bool micro;
  final String pseudoJeu;
  final String discord;
  final int nombreJoueurs;
  final int dureeMinutes;
  final String description;
  final DateTime dateCreation;

  Annonce({
    required this.id,
    required this.userId,
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

  factory Annonce.fromMap(String id, Map<String, dynamic> data) {
    return Annonce(
      id: id,
      userId: data['userId'] ?? '',
      pseudo: data['pseudo'] ?? '',
      age: data['age'] ?? 0,
      jeu: data['jeu'] ?? '',
      rangMin: data['rangMin'] ?? '',
      rangMax: data['rangMax'] ?? '',
      plateforme: data['plateforme'] ?? '',
      roles: List<String>.from(data['roles'] ?? const []),
      micro: data['micro'] ?? false,
      pseudoJeu: data['pseudoJeu'] ?? '',
      discord: data['discord'] ?? '',
      nombreJoueurs: data['nombreJoueurs'] ?? 1,
      dureeMinutes: data['dureeMinutes'] ?? 60,
      description: data['description'] ?? '',
      dateCreation: DateTime.tryParse(data['dateCreation'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
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
