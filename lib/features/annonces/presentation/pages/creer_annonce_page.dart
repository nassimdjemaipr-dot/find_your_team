import 'package:flutter/material.dart';
import '../../models/annonce.dart';
import '../../data/annonce_repository.dart';
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

  final _pseudoController = TextEditingController();
  final _ageController = TextEditingController();
  final _jeuController = TextEditingController();
  final _rangMinController = TextEditingController();
  final _rangMaxController = TextEditingController();
  final _plateformeController = TextEditingController();
  final _pseudoJeuController = TextEditingController();
  final _discordController = TextEditingController();
  final _nombreJoueursController = TextEditingController();
  final _dureeMinutesController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _rolesSelectionnees = [];
  final List<String> _rolesDisponibles = ['ADC', 'Support', 'Mid', 'Top', 'Jungle'];

  @override
  void dispose() {
    _pseudoController.dispose();
    _ageController.dispose();
    _jeuController.dispose();
    _rangMinController.dispose();
    _rangMaxController.dispose();
    _plateformeController.dispose();
    _pseudoJeuController.dispose();
    _discordController.dispose();
    _nombreJoueursController.dispose();
    _dureeMinutesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rolesSelectionnees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un rôle')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final annonce = Annonce(
        id: '',
        pseudo: _pseudoController.text,
        age: int.parse(_ageController.text),
        jeu: _jeuController.text,
        rangMin: _rangMinController.text,
        rangMax: _rangMaxController.text,
        plateforme: _plateformeController.text,
        roles: _rolesSelectionnees,
        micro: true,
        pseudoJeu: _pseudoJeuController.text,
        discord: _discordController.text,
        nombreJoueurs: int.parse(_nombreJoueursController.text),
        dureeMinutes: int.parse(_dureeMinutesController.text),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _pseudoController,
                decoration: const InputDecoration(hintText: 'Pseudo'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(hintText: 'Âge'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jeuController,
                decoration: const InputDecoration(hintText: 'Jeu (ex: Valorant)'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
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
                decoration: const InputDecoration(hintText: 'Plateforme (PC, PS5...)'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              const Text('Rôles recherchés', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _rolesDisponibles.map((role) {
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
              TextFormField(
                controller: _dureeMinutesController,
                decoration: const InputDecoration(hintText: 'Durée (minutes)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
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
                    backgroundColor: AppTheme.violet,
                    disabledBackgroundColor: AppTheme.bordure,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Publier l\'annonce',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
