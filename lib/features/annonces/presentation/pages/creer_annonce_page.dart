import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/annonce.dart';
import '../../data/annonce_repository.dart';
import 'package:find_your_team/core/jeux.dart';
import 'package:find_your_team/core/theme/app_theme.dart';

class CreerAnnoncePage extends StatefulWidget {
  const CreerAnnoncePage({super.key});

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

  // La liste des jeux et leurs roles viennent de core/jeux.dart :
  // une seule source pour le formulaire, les filtres et la vue par jeu.
  // Sans ca, une annonce creee ici pourrait ne jamais apparaitre
  // dans les filtres (nom de jeu ou de role different).
  final List<String> _jeux = nomsJeux;

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

      await _repository.ajouterAnnonce(annonce);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce créée avec succès !')),
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
        title: const Text('Nouvelle annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
