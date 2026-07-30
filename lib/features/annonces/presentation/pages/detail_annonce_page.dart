import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/stockage/favoris_service.dart';
import '../../models/annonce.dart';
import '../../data/annonce_repository.dart';

class DetailAnnoncePage extends StatefulWidget {
  final Annonce annonce;

  const DetailAnnoncePage({super.key, required this.annonce});

  @override
  State<DetailAnnoncePage> createState() => _DetailAnnoncePageState();
}

class _DetailAnnoncePageState extends State<DetailAnnoncePage> {
  late bool _estFavori;

  @override
  void initState() {
    super.initState();
    _estFavori = FavorisService.isFavori(widget.annonce.id);
  }

  void _toggleFavori() async {
    await FavorisService.toggle(widget.annonce.id);
    setState(() {
      _estFavori = FavorisService.isFavori(widget.annonce.id);
    });
  }

  bool get _estMonAnnonce {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return userId == widget.annonce.userId;
  }

  String _getImagePath() {
    final jeu = widget.annonce.jeu.toLowerCase().trim();

    if (jeu.contains('valorant')) {
      return 'assets/images/jeux/valorant.webp';
    }
    if (jeu.contains('rocket')) {
      return 'assets/images/jeux/rocket_league.jpg';
    }
    if (jeu.contains('league') || jeu.contains('lol')) {
      return 'assets/images/jeux/lol.jpg';
    }
    if (jeu.contains('cs:go') || jeu.contains('csgo') || jeu.contains('counter') || jeu.contains('strike')) {
      return 'assets/images/jeux/csgo.jpg';
    }

    return 'assets/images/jeux/valorant.webp';
  }

  Future<void> _contacterDiscord(BuildContext context) async {
    final discordUrl = 'discord://${widget.annonce.discord}';
    try {
      if (await canLaunchUrl(Uri.parse(discordUrl))) {
        await launchUrl(Uri.parse(discordUrl));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Discord : ${widget.annonce.discord}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Discord : ${widget.annonce.discord}')),
        );
      }
    }
  }

  Future<void> _supprimerAnnonce(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await AnnonceRepository().supprimerAnnonce(widget.annonce.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Annonce supprimée')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = context.couleurs;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.annonce.jeu),
        actions: [
          IconButton(
            icon: Icon(
              _estFavori ? Icons.star : Icons.star_border,
              color: _estFavori ? context.couleurs.primary : null,
            ),
            onPressed: _toggleFavori,
          ),
          if (_estMonAnnonce)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _supprimerAnnonce(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getImagePath()),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      couleurs.surface.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.annonce.jeu,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: couleurs.primary.withValues(alpha: 0.2),
                        child: Text(
                          widget.annonce.pseudo.isNotEmpty
                              ? widget.annonce.pseudo[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: couleurs.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.annonce.pseudo,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: couleurs.onSurface,
                              ),
                            ),
                            Text(
                              '${widget.annonce.age} ans',
                              style: TextStyle(
                                fontSize: 14,
                                color: couleurs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionInfo(
                    title: 'Infos du jeu',
                    children: [
                      _InfoRow(
                        icon: Icons.leaderboard,
                        label: 'Rang',
                        value: '${widget.annonce.rangMin} → ${widget.annonce.rangMax}',
                      ),
                      _InfoRow(
                        icon: Icons.videogame_asset,
                        label: 'Plateforme',
                        value: widget.annonce.plateforme,
                      ),
                      _InfoRow(
                        icon: Icons.person,
                        label: 'Pseudo jeu',
                        value: widget.annonce.pseudoJeu,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionInfo(
                    title: 'Critères',
                    children: [
                      _InfoRow(
                        icon: Icons.mic,
                        label: 'Micro',
                        value: widget.annonce.micro ? 'Obligatoire' : 'Non obligatoire',
                      ),
                      _InfoRow(
                        icon: Icons.group,
                        label: 'Joueurs recherchés',
                        value: '${widget.annonce.nombreJoueurs}',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rôles', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: widget.annonce.roles.map((role) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        couleurs.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      color: couleurs.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.annonce.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          widget.annonce.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: couleurs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (!_estMonAnnonce)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _contacterDiscord(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: couleurs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.discord, size: 20),
                        label: const Text('Contacter sur Discord'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionInfo extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionInfo({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final couleurs = context.couleurs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: couleurs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: couleurs.outlineVariant),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final couleurs = context.couleurs;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: couleurs.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: couleurs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
