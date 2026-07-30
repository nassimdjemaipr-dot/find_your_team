// ============================================================
// ÉCRAN Connexion / Inscription (tache #5).
// Un seul ecran avec un interrupteur entre les deux modes,
// pour eviter de dupliquer le formulaire.
// StatefulWidget car le mode, le chargement et la visibilite
// du mot de passe changent l'affichage.
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/auth_repository.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _auth = AuthRepository();

  // Cle du formulaire : sert a declencher la validation des champs.
  final _formKey = GlobalKey<FormState>();

  final _pseudoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();

  bool _inscription = false; // false = connexion, true = inscription
  bool _chargement = false;
  bool _mdpCache = true;

  @override
  void dispose() {
    // On libere les controleurs pour eviter les fuites memoire.
    _pseudoCtrl.dispose();
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  // Envoie le formulaire (connexion ou inscription selon le mode).
  Future<void> _valider() async {
    // Si un champ est invalide, on s'arrete la.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _chargement = true);

    try {
      if (_inscription) {
        await _auth.inscription(
          email: _emailCtrl.text,
          motDePasse: _mdpCtrl.text,
          pseudo: _pseudoCtrl.text,
        );
      } else {
        await _auth.connexion(
          email: _emailCtrl.text,
          motDePasse: _mdpCtrl.text,
        );
      }
      // Pas de Navigator ici : l'AuthGate ecoute la connexion
      // et bascule tout seul vers le fil d'annonces.
    } on FirebaseAuthException catch (e) {
      // On verifie que l'ecran est toujours affiche avant d'utiliser context.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthRepository.messageErreur(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  // Bascule entre connexion et inscription.
  void _changerMode() {
    setState(() {
      _inscription = !_inscription;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo / titre ---
                  Container(
                    height: 72,
                    width: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.couleurs.primary, const Color(0xFF5F4FF5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.sports_esports,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Find Your Team',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.couleurs.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _inscription
                        ? 'Cree ton compte et trouve ton equipe'
                        : 'Content de te revoir !',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.couleurs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // --- Pseudo (uniquement en inscription) ---
                  if (_inscription) ...[
                    TextFormField(
                      controller: _pseudoCtrl,
                      style: TextStyle(color: context.couleurs.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Ton pseudo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Choisis un pseudo';
                        }
                        if (v.trim().length < 3) {
                          return 'Au moins 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                  ],

                  // --- Email ---
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: context.couleurs.onSurface),
                    decoration: const InputDecoration(
                      hintText: 'Adresse email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Entre ton email';
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // --- Mot de passe ---
                  TextFormField(
                    controller: _mdpCtrl,
                    obscureText: _mdpCache,
                    style: TextStyle(color: context.couleurs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mdpCache ? Icons.visibility_off : Icons.visibility,
                          color: context.couleurs.onSurfaceVariant,
                        ),
                        onPressed: () => setState(() => _mdpCache = !_mdpCache),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Entre ton mot de passe';
                      }
                      if (v.length < 6) {
                        return 'Au moins 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- Bouton principal ---
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      // Desactive pendant le chargement pour eviter
                      // les doubles envois.
                      onPressed: _chargement ? null : _valider,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.couleurs.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: context.couleurs.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _chargement
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _inscription ? "S'inscrire" : 'Se connecter',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Lien pour changer de mode ---
                  TextButton(
                    onPressed: _chargement ? null : _changerMode,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: context.couleurs.onSurfaceVariant, fontSize: 14),
                        children: [
                          TextSpan(
                            text: _inscription
                                ? 'Deja un compte ? '
                                : 'Pas encore de compte ? ',
                          ),
                          TextSpan(
                            text: _inscription ? 'Se connecter' : "S'inscrire",
                            style: TextStyle(
                              color: context.couleurs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
