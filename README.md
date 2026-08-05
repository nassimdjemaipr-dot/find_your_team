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
| **Cloud Firestore** | Base de données **distante** (collection `annonces`, en temps réel) |
| **Hive** | Base de données **locale** (thème sombre / clair, favoris) |
| **url_launcher** | Ouvrir Discord depuis une annonce |

### Les deux stockages

Le module demandait **deux systèmes de stockage** : nous avons choisi de les
séparer par nature de la donnée.

| | Firestore (distant) | Hive (local) |
|---|---|---|
| **Contenu** | Les annonces — partagées entre tous les joueurs | Les préférences de l'appareil |
| **Exemples** | jeu, rangs, rôles, Discord, auteur | thème sombre / clair, liste des favoris |
| **Pourquoi ce choix** | Une annonce n'a de sens que si les autres la voient : elle doit être synchronisée et temps réel | Un thème ou un favori est **personnel à l'appareil**, inutile de faire un aller-retour réseau |

## 🏗️ Architecture

Le projet suit une **Clean Architecture (Feature-First)** : le code est séparé en couches claires pour respecter le critère du module.

```
lib/
├── main.dart                  # initialise Firebase + Hive, applique le thème
├── firebase_options.dart      # généré par flutterfire configure
│
├── core/                      # ce qui sert à toute l'application
│   ├── jeux.dart              # les jeux, leurs rôles, leurs visuels
│   ├── theme/app_theme.dart   # thèmes sombre et clair
│   └── stockage/              # Hive : préférences et favoris
│
└── features/
    ├── auth/
    │   ├── data/              # AuthRepository (Firebase Auth)
    │   └── presentation/      # écran de connexion + AuthGate
    ├── annonces/
    │   ├── models/            # Annonce (POO) : fromMap / toMap
    │   ├── data/              # AnnonceRepository (Firestore)
    │   └── presentation/      # pages + widgets
    └── profil/
        └── presentation/      # profil, thème, mes annonces, mes favoris
```

**Pourquoi cette architecture ?**
- **Séparation des responsabilités** : l'UI ne connaît pas Firestore, elle appelle
  le repository ; le repository ne connaît pas l'UI.
- **Une feature = un dossier** : tout ce qui concerne les annonces est au même
  endroit, du modèle jusqu'à l'écran.
- **Travail à deux** : on touche rarement aux mêmes fichiers, donc peu de
  conflits Git.

### Les deux couches de données

| Classe | Rôle |
|--------|------|
| `Annonce` | Le modèle POO. `Annonce.fromMap()` construit un objet depuis Firestore, `toMap()` fait l'inverse. Il n'importe **pas** `cloud_firestore` : l'UI peut l'utiliser sans dépendre de Firebase. |
| `AnnonceRepository` | Le seul endroit qui parle à Firestore : `annoncesStream()`, `ajouterAnnonce()`, `modifierAnnonce()`, `supprimerAnnonce()`, `mesAnnonces()`. |
| `AuthRepository` | Le seul endroit qui parle à Firebase Auth, et qui traduit ses codes d'erreur en français. |
| `PreferencesService` / `FavorisService` | Les deux accès à Hive (thème, favoris). |

## ✅ Fonctionnalités

**Compte**
- 🔐 Inscription, connexion, déconnexion
- 🚪 `AuthGate` : l'application bascule seule entre l'écran de connexion et
  l'accueil, sans navigation manuelle

**Annonces**
- 📝 Publier une annonce : jeu, âge, rangs min/max, plateforme, rôles
  recherchés, micro, pseudo en jeu, Discord, nombre de joueurs, durée
- 📰 Fil en **temps réel** : une annonce publiée apparaît immédiatement chez
  les autres joueurs
- 🔍 Recherche + panneau de filtres (jeu, rôle, plateforme, micro, âge)
- 🎮 Vue **par jeu** : une carte par jeu avec son nombre d'annonces
- 📄 Écran de détail au clic sur une annonce
- ✏️ Modifier et 🗑️ supprimer **ses propres** annonces
- 💬 Contacter un joueur sur Discord

**Personnalisation**
- 🌗 Thème sombre / clair, retenu au redémarrage
- ⭐ Favoris, conservés en local
- 👤 Profil : mes annonces et mes favoris

## 🔒 Sécurité

Les règles Firestore n'autorisent l'écriture qu'aux utilisateurs connectés, et
seul l'auteur d'une annonce peut la modifier ou la supprimer. Voir
[`firestore.rules`](firestore.rules).

## 🧪 Tests

```bash
flutter test
```

Nous testons la **logique pure** (modèle, filtres, jeux) plutôt que les écrans :
depuis que le fil lit Firestore, tester l'interface demanderait d'initialiser
Firebase, ce qui n'a pas de sens dans un test unitaire.

## 🚀 Lancer le projet

```bash
flutter pub get
flutter run
```

La configuration Firebase (`lib/firebase_options.dart`) est versionnée : il n'y
a rien à configurer pour lancer le projet.

## 📄 Documentation

- [`MODELE_DONNEES.md`](MODELE_DONNEES.md) — les champs de la collection
  `annonces`, leurs types, les rôles par jeu et les règles de sécurité. Ce
  document nous a servi de référence commune pour travailler en parallèle.

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
Après recherche, ce n'est **pas possible** : Discord n'expose aucun lien
permettant d'ouvrir une conversation à partir d'un simple pseudo, et aucune API
ne permet de pré-remplir un message. C'est volontaire de leur part, pour limiter
le spam.

**Solution retenue :** on tente d'ouvrir l'application Discord avec
`url_launcher` (schéma `discord://`). Si l'application n'est pas installée ou
que le lien n'aboutit pas, on affiche le pseudo Discord dans un `SnackBar` pour
que le joueur puisse le recopier.

**Ce qu'on en retient :** avant de promettre une fonctionnalité, il faut
vérifier ce que le service tiers autorise réellement — et prévoir un repli
utilisable quand la réponse est non.

### 7. Mise en place de l'environnement

Côté configuration, plusieurs blocages Windows au démarrage :

- `flutterfire` inutilisable tant que la politique d'exécution PowerShell n'était
  pas passée en `RemoteSigned`.
- « Building with plugins requires symlink support » : il fallait activer le
  **mode développeur** de Windows.
- Les comptes créés n'apparaissaient pas dans Firestore — normal : les comptes
  vivent dans **Authentication → Users**, pas dans la base de données. Deux
  espaces distincts dans la console Firebase.

### 8. Deux sources de données en même temps

Le bug le plus instructif du projet. Un joueur publiait une annonce : elle
apparaissait bien dans l'onglet **Annonces**, mais l'onglet **Par jeu** restait
figé sur les mêmes chiffres.

La cause : on avait développé l'interface avec une liste d'annonces écrite en
dur (`annonces_factices.dart`), le temps que Firestore soit prêt. Quand le fil a
été branché sur la base, **les deux autres écrans ont été oubliés**. L'app
lisait donc deux sources différentes selon l'onglet.

**Correction :** brancher les trois écrans sur le même `annoncesStream()`, puis
**supprimer complètement** le fichier de données de démonstration.

**Ce qu'on en retient :** des données de test, c'est très pratique pour avancer
sans attendre la base — mais il faut les retirer dès que la vraie source
existe, sinon on ne sait plus ce que l'application affiche vraiment.

### 9. Des données qui ne se retrouvent pas

Le formulaire proposait le jeu « Counter-Strike 2 » alors que les cartes de
l'accueil affichaient « CS:GO ». Une annonce créée depuis le formulaire
n'apparaissait donc **jamais** sous sa carte : pour le code, ce sont deux
chaînes de caractères différentes.

Le même problème existait pour les rôles, écrits à deux endroits.

**Correction :** créer [`lib/core/jeux.dart`](lib/core/jeux.dart), une source
unique qui contient les jeux, leurs rôles et leurs visuels. Le formulaire, les
filtres et la vue par jeu la lisent tous.

**Ce qu'on en retient :** dès qu'une même liste est recopiée à deux endroits,
elle finit par diverger. Ajouter un jeu ne demande maintenant qu'**une seule
ligne**.

### 10. Un choix d'architecture ne vaut que s'il est suivi partout

Suite du point 4. Une fois les couleurs passées par le thème, le formulaire
utilisait toujours les anciennes couleurs fixes : il restait sombre même en
thème clair, avec du texte illisible.

**Ce qu'on en retient :** quand une convention change en cours de projet, il
faut la **communiquer et la documenter**, sinon le code écrit en parallèle
continue sur l'ancienne façon de faire.
