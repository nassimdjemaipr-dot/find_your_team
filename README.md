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
| **Hive** | Base de données locale (thème sombre / clair) |

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

### 1. Travailler à deux sur les mêmes fichiers (conflits Git)

Notre premier vrai blocage. Pendant que l'un branchait Firebase dans `main.dart`,
l'autre y branchait l'écran d'accueil. Résultat : un conflit Git au moment de la
Pull Request, avec un message « This branch has conflicts that must be resolved ».

**Ce qu'on a compris :** un conflit n'est pas une erreur, c'est Git qui demande
un arbitrage humain parce que deux personnes ont modifié les mêmes lignes.

**Comment on l'a résolu :** on a gardé les deux apports (l'initialisation Firebase
*et* le nouvel écran d'accueil) au lieu d'en choisir un.

**Ce qu'on a changé ensuite :** faire `git pull origin main` régulièrement sur sa
branche, au lieu d'attendre la fin de la tâche. Les petits conflits sont bien plus
faciles à régler que les gros.

### 2. Coder sur une base qui a évolué entre-temps

Le formulaire de création d'annonce a été commencé avant qu'on ajoute le champ
`userId` au modèle `Annonce`. Au moment de fusionner, le code ne compilait plus :
il manquait un paramètre obligatoire dans le constructeur.

**Ce qu'on en retient :** quand on travaille en parallèle, il faut se mettre
d'accord sur le **modèle de données avant** de coder. C'est pour ça qu'on a écrit
un document commun [`MODELE_DONNEES.md`](MODELE_DONNEES.md) : chaque champ, son
type et son rôle, validé par les deux.

### 3. Le champ `userId` oublié

En relisant le repository, on est tombés sur `where('pseudo', isEqualTo: userId)` :
la requête cherchait un identifiant Firebase dans le champ « pseudo », donc elle ne
renvoyait jamais rien.

La cause réelle : le modèle n'avait **aucun champ** reliant une annonce à son auteur.
Sans lui, impossible d'afficher « mes annonces », et impossible d'écrire des règles
de sécurité (n'importe qui aurait pu supprimer l'annonce d'un autre).

**Correction :** ajout de `userId` (l'UID Firebase) dans le modèle, et requête
corrigée en `where('userId', isEqualTo: userId)`.

### 4. Des couleurs codées en dur, impossibles à thémer

On avait écrit nos couleurs dans une classe `AppTheme` avec des constantes
(`AppTheme.surface`, `AppTheme.violet`...). Ça marchait très bien... tant qu'il n'y
avait qu'un seul thème. Au moment d'ajouter le thème clair, il a fallu reprendre
**55 utilisations** réparties dans 8 fichiers.

**La bonne approche :** passer par le `ColorScheme` de Flutter. Les écrans ne
connaissent plus les couleurs, ils demandent « la couleur de surface » ou « la
couleur principale », et c'est le thème actif qui répond.

**Effet de bord instructif :** beaucoup de widgets étaient déclarés `const`. Or une
couleur qui dépend du contexte n'est plus une constante — il a fallu retirer ces
`const`. Ça nous a fait comprendre concrètement ce que `const` implique en Dart :
une valeur connue à la compilation, pas à l'exécution.

### 5. Les images des jeux

Deux petits pièges d'affilée :

- Un fichier nommé `league of legends.jpg` : les **espaces dans les noms de
  fichiers** posent problème. Renommé en `lol.jpg`.
- Une image au format `.webp` alors que le code attendait `.jpg`. Flutter gère
  très bien le WebP (et c'est même plus léger), il suffisait d'écrire le bon
  chemin.

On a aussi prévu un `errorBuilder` : si une image manque, la carte retombe sur un
dégradé de couleur au lieu de casser l'affichage.

### 6. Contacter un joueur sur Discord

On voulait qu'un clic ouvre directement une conversation Discord avec le joueur.
Après recherche : **Discord ne le permet pas** depuis un simple pseudo, et aucune
API ne permet de pré-remplir un message (protection anti-spam).

**Solution retenue :** accepter soit un lien d'invitation de serveur
(`discord.gg/...`), qui ouvre l'application Discord directement, soit un simple
pseudo, qui est alors copié dans le presse-papier.

### 7. Mise en place de l'environnement

Côté configuration, plusieurs blocages Windows au démarrage :

- `flutterfire` inutilisable tant que la politique d'exécution PowerShell n'était
  pas passée en `RemoteSigned`.
- « Building with plugins requires symlink support » : il fallait activer le
  **mode développeur** de Windows.
- Les comptes créés n'apparaissaient pas dans Firestore — normal : les comptes
  vivent dans **Authentication → Users**, pas dans la base de données. Deux
  espaces distincts dans la console Firebase.
