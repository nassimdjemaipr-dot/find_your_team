# 🎮 Find Your Team

Application mobile **esport** pour trouver des coéquipiers. Chaque joueur publie une annonce (jeu, rang, plateforme, rôle recherché, micro, Discord) et parcourt celles des autres, en temps réel.

> Projet final du module **Dart & Flutter** — IPSSI.

---

## 🎯 Objectif

Résoudre un vrai problème des joueurs : **trouver rapidement une équipe** à son niveau. L'utilisateur poste une annonce, filtre par jeu, et contacte les joueurs qui l'intéressent.

## 👥 Groupe

- **DJEMAI Nassim**
- **BLANCHI Melvyn**

## 🛠️ Stack technique

| Technologie | Rôle |
|-------------|------|
| **Flutter / Dart** | Framework et langage |
| **Firebase Authentication** | Inscription / connexion |
| **Cloud Firestore** | Base de données distante (collection `annonces`) |
| **SharedPreferences** | Stockage local (thème sombre / clair) |

## 🏗️ Architecture

Le projet suit une **Clean Architecture (Feature-First)** : le code est séparé en couches claires pour respecter le critère du module.

```
lib/
├── main.dart
├── core/              # thème, stockage local (SharedPreferences)
└── features/annonces/
    ├── models/        # modèles POO (Annonce) + constructeurs fromFirestore
    ├── data/          # accès Firestore (repository)
    └── presentation/  # UI : pages + widgets
```

**Pourquoi cette architecture ?**
- **Séparation des responsabilités** : l'UI ne connaît pas les détails de Firestore, la data ne connaît pas l'UI.
- **Testable et maintenable** : chaque couche évolue indépendamment.
- **Travail à 2** : chacun bosse dans sa couche (data / UI) sans conflits Git.

## ✅ Fonctionnalités

- 🔐 Authentification (inscription / connexion / déconnexion)
- 📝 Créer une annonce (jeu, rang, plateforme, rôle, micro, Discord)
- 📰 Fil d'annonces en temps réel + filtres par jeu
- 🗑️ Gérer ses propres annonces (CRUD)
- 👤 Profil + thème sombre / clair (mémorisé en local)

## 🚀 Lancer le projet

```bash
flutter pub get
flutter run
```

## 🧗 Difficultés rencontrées

*(À compléter au fil du développement.)*
