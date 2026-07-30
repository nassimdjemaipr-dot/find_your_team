// ============================================================
// AUTH REPOSITORY
// Toute la logique de connexion / inscription passe par ici.
// L'UI n'appelle jamais FirebaseAuth directement : elle passe
// par cette classe (separation des responsabilites).
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Flux qui previent a chaque connexion / deconnexion.
  // C'est ce que l'AuthGate ecoute pour savoir quel ecran afficher.
  Stream<User?> get utilisateurCourant => _auth.authStateChanges();

  // L'utilisateur connecte (null si personne).
  User? get utilisateur => _auth.currentUser;

  // --- Inscription ---
  Future<void> inscription({
    required String email,
    required String motDePasse,
    required String pseudo,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
    // On enregistre le pseudo sur le compte Firebase pour pouvoir
    // l'afficher ensuite (dans le profil, sur les annonces...).
    await credential.user?.updateDisplayName(pseudo.trim());
  }

  // --- Connexion ---
  Future<void> connexion({
    required String email,
    required String motDePasse,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
  }

  // --- Deconnexion ---
  Future<void> deconnexion() => _auth.signOut();

  // Traduit les codes d'erreur Firebase en messages comprehensibles.
  static String messageErreur(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "L'adresse email n'est pas valide.";
      case 'email-already-in-use':
        return 'Un compte existe deja avec cet email.';
      case 'weak-password':
        return 'Le mot de passe doit faire au moins 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Pas de connexion internet.';
      case 'too-many-requests':
        return 'Trop de tentatives. Reessaie plus tard.';
      default:
        return 'Une erreur est survenue. Reessaie.';
    }
  }
}