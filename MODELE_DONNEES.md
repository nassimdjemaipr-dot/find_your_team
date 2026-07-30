# 📊 Modèle de données — Find Your Team

Document de référence pour que le **back** (Firestore) et le **front** (UI) parlent le même langage.
Toute modification ici doit être validée par les deux membres du groupe.

---

## 🗂️ Structure Firestore

```
annonces/                  ← collection
   └── {annonceId}         ← document (id généré par Firestore)
```

Une seule collection : `annonces`. Le champ `userId` permet de retrouver les annonces d'un joueur.

---

## 🧩 Document `annonces/{annonceId}`

| Champ | Type Dart | Type Firestore | Défaut si absent | Description |
|-------|-----------|----------------|------------------|-------------|
| `userId` | `String` | string | `''` | UID Firebase de l'auteur (⚠️ sert aux règles de sécurité et à "mes annonces") |
| `pseudo` | `String` | string | `''` | Pseudo du compte |
| `age` | `int` | number | `0` | Âge du joueur |
| `jeu` | `String` | string | `''` | Valorant, League of Legends, Counter-Strike 2, Rocket League |
| `rangMin` | `String` | string | `''` | Rang minimum recherché |
| `rangMax` | `String` | string | `''` | Rang maximum recherché |
| `plateforme` | `String` | string | `''` | PC, PS5, Xbox, Switch |
| `roles` | `List<String>` | array de string | `[]` | Rôles recherchés (plusieurs possibles) |
| `micro` | `bool` | boolean | `false` | Micro obligatoire ou non |
| `pseudoJeu` | `String` | string | `''` | Pseudo utilisé **dans** le jeu |
| `discord` | `String` | string | `''` | Identifiant Discord pour contacter |
| `nombreJoueurs` | `int` | number | `1` | Nombre de joueurs recherchés |
| `dureeMinutes` | `int` | number | `60` | Durée de validité de l'annonce |
| `description` | `String` | string | `''` | Texte libre |
| `dateCreation` | `DateTime` | string (ISO 8601) | `DateTime.now()` | Date de publication |

> **Note sur `dateCreation`** : stockée en **String ISO 8601** (`toIso8601String()`), pas en `Timestamp`.
> Ça évite d'importer `cloud_firestore` dans le modèle → le front peut l'utiliser sans Firebase.

---

## 📄 Exemple de document

```json
{
  "userId": "kJ8xQ2mNpR...",
  "pseudo": "NoScopeKing",
  "age": 19,
  "jeu": "Valorant",
  "rangMin": "Or",
  "rangMax": "Platine",
  "plateforme": "PC",
  "roles": ["Duelliste", "Initiateur"],
  "micro": true,
  "pseudoJeu": "NoScope#EUW",
  "discord": "noscopeking",
  "nombreJoueurs": 2,
  "dureeMinutes": 120,
  "description": "On cherche 2 joueurs chill pour ranked ce soir.",
  "dateCreation": "2026-07-30T18:30:00.000"
}
```

---

## 🔌 Comment l'utiliser (côté repository)

Le modèle est déjà écrit dans [`lib/features/annonces/models/annonce.dart`](lib/features/annonces/models/annonce.dart).
Il expose deux méthodes :

```dart
// Firestore -> objet Annonce
Annonce.fromMap(doc.id, doc.data())

// objet Annonce -> Firestore
annonce.toMap()
```

### Exemple d'utilisation dans `AnnonceRepository`

```dart
final _db = FirebaseFirestore.instance;

// Lecture temps réel de toutes les annonces
Stream<List<Annonce>> annoncesStream() {
  return _db
      .collection('annonces')
      .orderBy('dateCreation', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => Annonce.fromMap(doc.id, doc.data()))
          .toList());
}

// Ajout d'une annonce
Future<void> ajouterAnnonce(Annonce annonce) {
  return _db.collection('annonces').add(annonce.toMap());
}

// Suppression
Future<void> supprimerAnnonce(String id) {
  return _db.collection('annonces').doc(id).delete();
}

// Les annonces d'un joueur (pour l'écran Profil)
Stream<List<Annonce>> mesAnnonces(String userId) {
  return _db
      .collection('annonces')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => Annonce.fromMap(doc.id, doc.data()))
          .toList());
}
```

---

## 📛 Noms de méthodes convenus

Pour que le front puisse appeler le repository sans surprise :

| Méthode | Signature | Rôle |
|---------|-----------|------|
| `annoncesStream()` | `Stream<List<Annonce>>` | Toutes les annonces en temps réel |
| `ajouterAnnonce(Annonce)` | `Future<void>` | Publier une annonce |
| `supprimerAnnonce(String id)` | `Future<void>` | Supprimer une annonce |
| `mesAnnonces(String userId)` | `Stream<List<Annonce>>` | Les annonces d'un joueur |

---

## 🔒 Règles de sécurité prévues (tâche #6)

```js
match /annonces/{id} {
  // Tout le monde connecté peut lire les annonces
  allow read: if request.auth != null;

  // On ne peut créer qu'une annonce à son propre nom
  allow create: if request.auth != null
                && request.resource.data.userId == request.auth.uid;

  // On ne peut modifier / supprimer que SES annonces
  allow update, delete: if request.auth != null
                        && resource.data.userId == request.auth.uid;
}
```

---

## 🎛️ Valeurs possibles (utilisées par les filtres du fil)

| Filtre | Valeurs |
|--------|---------|
| **Jeu** | Tous · Valorant · League of Legends · Counter-Strike 2 · Rocket League |
| **Rôle** | Tous · Duelliste · Initiateur · Support · Entry · AWP · 2v2 |
| **Plateforme** | Tous · PC · PS5 · Xbox · Switch |
| **Micro** | Peu importe · Avec micro · Sans micro |
| **Âge** | Tous · 16+ · 18+ · 21+ |
