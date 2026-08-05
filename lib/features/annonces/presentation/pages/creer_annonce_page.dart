import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/annonce.dart';
import '../../data/annonce_repository.dart';
import 'package:find_your_team/core/jeux.dart';
import 'package:find_your_team/core/stockage/profil_joueur_service.dart';
import 'package:find_your_team/core/theme/app_theme.dart';

class CreerAnnoncePage extends StatefulWidget {
  final Annonce? annonceAModifier;

  const CreerAnnoncePage({super.key, this.annonceAModifier});

  @override
  State<CreerAnnoncePage> createState() => _CreerAnnoncePageState();
}

class _CreerAnnoncePageState extends State<CreerAnnoncePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AnnonceRepository();
  bool _isLoading = false;

  final _ageController = TextEditingController();
  final _rangMinController = TextEditingController();
  final _rangMaxController = TextEditingController();
  final _plateformeController = TextEditingController();
  final _pseudoJeuController = TextEditingController();
  final _discordController = TextEditingController();
  final _nombreJoueursController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _jeuSelectionne;
  final List<String> _rolesSelectionnees = [];
  DateTime? _dateFinAnnonce;
  bool _microDisponible = true;

  final List<String> _jeux = nomsJeux;

  bool get _enModeEdition => widget.annonceAModifier != null;

  // Vrai si on a rempli le formulaire depuis les infos enregistrees
  // en local : sert a afficher un petit message a l'utilisateur.
  bool _preRempli = false;

  @override
  void initState() {
    super.initState();
    if (_enModeEdition) {
      final annonce = widget.annonceAModifier!;
      _ageController.text = annonce.age.toString();
      _jeuSelectionne = annonce.jeu;
      _rangMinController.text = annonce.rangMin;
      _rangMaxController.text = annonce.rangMax;
      _plateformeController.text = annonce.plateforme;
      _pseudoJeuController.text = annonce.pseudoJeu;
      _discordController.text = annonce.discord;
      _nombreJoueursController.text = annonce.nombreJoueurs.toString();
      _descriptionController.text = annonce.description;
      _rolesSelectionnees.addAll(annonce.roles);
      _microDisponible = annonce.micro;
      _dateFinAnnonce = DateTime.now().add(Duration(minutes: annonce.dureeMinutes));
    } else {
      // Nouvelle annonce : on reprend les informations du joueur
      // enregistrees en local lors de sa derniere publication.
      // On ne pre-remplit que les champs qui ne changent pas d'une
      // annonce a l'autre (l'age, la plateforme, les pseudos).
      _ageController.text = ProfilJoueurService.age;
      _plateformeController.text = ProfilJoueurService.plateforme;
      _pseudoJeuController.text = ProfilJoueurService.pseudoJeu;
      _discordController.text = ProfilJoueurService.discord;
      _preRempli = ProfilJoueurService.aDesInfos;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _rangMinController.dispose();
    _rangMaxController.dispose();
    _plateformeController.dispose();
    _pseudoJeuController.dispose();
    _discordController.dispose();
    _nombreJoueursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jeuSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un jeu')),
      );
      return;
    }
    if (_rolesSelectionnees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un rôle')),
      );
      return;
    }
    if (_dateFinAnnonce == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une date de fin')),
      );
      return;
    }

    // On relie l'annonce a son auteur : indispensable pour "mes annonces"
    // et pour les regles de securite Firestore.
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dureeMinutes = _dateFinAnnonce!.difference(DateTime.now()).inMinutes;

      final annonce = Annonce(
        id: '',
        userId: userId,
        pseudo: _pseudoJeuController.text,
        age: int.parse(_ageController.text),
        jeu: _jeuSelectionne!,
        rangMin: _rangMinController.text,
        rangMax: _rangMaxController.text,
        plateforme: _plateformeController.text,
        roles: _rolesSelectionnees,
        micro: _microDisponible,
        pseudoJeu: _pseudoJeuController.text,
        discord: _discordController.text,
        nombreJoueurs: int.parse(_nombreJoueursController.text),
        dureeMinutes: dureeMinutes > 0 ? dureeMinutes : 60,
        description: _descriptionController.text,
        dateCreation: DateTime.now(),
      );

      if (_enModeEdition) {
        await _repository.modifierAnnonce(widget.annonceAModifier!.id, annonce);
      } else {
        await _repository.ajouterAnnonce(annonce);
      }

      // On retient les informations du joueur pour pre-remplir
      // sa prochaine annonce (stockage local Hive).
      await ProfilJoueurService.enregistrer(
        age: _ageController.text,
        plateforme: _plateformeController.text,
        pseudoJeu: _pseudoJeuController.text,
        discord: _discordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_enModeEdition ? 'Annonce modifiée avec succès !' : 'Annonce créée avec succès !')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesDisponibles = _jeuSelectionne != null
        ? jeuParNom(_jeuSelectionne!)?.roles ?? <String>[]
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(_enModeEdition ? 'Modifier l\'annonce' : 'Nouvelle annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bandeau affiche quand on a repris les infos enregistrees
              // lors de la derniere publication.
              if (_preRempli) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.couleurs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.couleurs.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 18, color: context.couleurs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'On a repris tes infos de la dernière annonce. '
                          'Tu peux les modifier.',
                          style: TextStyle(
                            color: context.couleurs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _ageController.clear();
                            _plateformeController.clear();
                            _pseudoJeuController.clear();
                            _discordController.clear();
                            _preRempli = false;
                          });
                        },
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(hintText: 'Âge'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _jeuSelectionne,
                decoration: const InputDecoration(
                  hintText: 'Choisir un jeu',
                  labelText: 'Jeu',
                ),
                isExpanded: true,
                items: _jeux
                    .map((jeu) => DropdownMenuItem(value: jeu, child: Text(jeu)))
                    .toList(),
                onChanged: (jeu) {
                  setState(() {
                    _jeuSelectionne = jeu;
                    _rolesSelectionnees.clear();
                  });
                },
                validator: (v) => v == null ? 'Sélectionnez un jeu' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rangMinController,
                      decoration: const InputDecoration(hintText: 'Rang min'),
                      validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rangMaxController,
                      decoration: const InputDecoration(hintText: 'Rang max'),
                      validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateformeController,
                decoration:
                    const InputDecoration(hintText: 'Plateforme (PC, PS5...)'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              if (_jeuSelectionne != null) ...[
                const Text('Rôles recherchés',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: rolesDisponibles.map((role) {
                    final isSelected = _rolesSelectionnees.contains(role);
                    return FilterChip(
                      label: Text(role),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _rolesSelectionnees.add(role);
                          } else {
                            _rolesSelectionnees.remove(role);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Sélectionnez un jeu pour voir les rôles',
                      style: TextStyle(color: context.couleurs.onSurfaceVariant, fontSize: 12)),
                ),
              Row(
                children: [
                  const Text('Micro disponible',
                      style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _microDisponible = !_microDisponible),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _microDisponible ? context.couleurs.primary : context.couleurs.outlineVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _microDisponible ? 'Oui' : 'Non',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pseudoJeuController,
                decoration: const InputDecoration(hintText: 'Pseudo du jeu'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discordController,
                decoration: const InputDecoration(hintText: 'Discord'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreJoueursController,
                decoration: const InputDecoration(hintText: 'Nombre de joueurs'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _dateFinAnnonce = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Date de fin de l\'annonce',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateFinAnnonce != null
                        ? '${_dateFinAnnonce!.day}/${_dateFinAnnonce!.month}/${_dateFinAnnonce!.year}'
                        : 'Choisir une date de fin',
                    style: TextStyle(
                      color: _dateFinAnnonce != null
                          ? Colors.white
                          : context.couleurs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
                maxLines: 4,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _soumettre,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: context.couleurs.primary,
                    disabledBackgroundColor: context.couleurs.outlineVariant,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Valider',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
