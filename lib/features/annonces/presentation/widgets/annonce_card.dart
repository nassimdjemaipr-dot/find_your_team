import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/stockage/favoris_service.dart';
import '../../models/annonce.dart';
import '../pages/detail_annonce_page.dart';
import 'statut_pastille.dart';

class AnnonceCard extends StatefulWidget {
  final Annonce annonce;

  const AnnonceCard({super.key, required this.annonce});

  @override
  State<AnnonceCard> createState() => _AnnonceCardState();
}

class _AnnonceCardState extends State<AnnonceCard> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => DetailAnnoncePage(annonce: widget.annonce),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.couleurs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.couleurs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // --- Ligne du haut : pseudo + jeu ---
          Row(
            children: [
              // Petite pastille avec la 1re lettre du pseudo.
              CircleAvatar(
                radius: 20,
                backgroundColor: context.couleurs.primary.withValues(alpha: 0.2),
                child: Text(
                  widget.annonce.pseudo.isNotEmpty ? widget.annonce.pseudo[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: context.couleurs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.annonce.pseudo,
                      style: TextStyle(
                        color: context.couleurs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Le jeu et l'etat de l'annonce sur la meme ligne.
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.annonce.jeu,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.couleurs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatutPastille(
                            statut: widget.annonce.statut, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge du nombre de joueurs recherchés.
              _Badge(
                icon: Icons.group,
                texte: '${widget.annonce.nombreJoueurs}',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _estFavori ? Icons.star : Icons.star_border,
                  color: _estFavori ? context.couleurs.primary : context.couleurs.onSurfaceVariant,
                ),
                onPressed: _toggleFavori,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --- Infos clés : rang + plateforme + micro ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Info(icon: Icons.leaderboard, texte: '${widget.annonce.rangMin} → ${widget.annonce.rangMax}'),
              _Info(icon: Icons.videogame_asset, texte: widget.annonce.plateforme),
              _Info(icon: Icons.cake_outlined, texte: '${widget.annonce.age} ans'),
              _Info(
                icon: widget.annonce.micro ? Icons.mic : Icons.mic_off,
                texte: widget.annonce.micro ? 'Micro' : 'Sans micro',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- Les rôles recherchés (chips violets) ---
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.annonce.roles.map((role) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: context.couleurs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role,
                  style: TextStyle(color: context.couleurs.primary, fontSize: 12),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          Text(
            widget.annonce.description,
            style: TextStyle(color: context.couleurs.onSurfaceVariant, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 14),

          // --- Bouton contacter sur Discord ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO (tâche #8) : ouvrir/copier le Discord de l'annonce.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Discord : ${widget.annonce.discord}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.couleurs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.discord, size: 18),
              label: const Text('Contacter sur Discord'),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// Petit badge arrondi (icône + texte).
class _Badge extends StatelessWidget {
  final IconData icon;
  final String texte;
  const _Badge({required this.icon, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.couleurs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.couleurs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: context.couleurs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(texte, style: TextStyle(color: context.couleurs.onSurface, fontSize: 13)),
        ],
      ),
    );
  }
}

// Une info clé (icône + texte) affichée sous le pseudo.
class _Info extends StatelessWidget {
  final IconData icon;
  final String texte;
  const _Info({required this.icon, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.couleurs.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(texte, style: TextStyle(color: context.couleurs.onSurface, fontSize: 13)),
      ],
    );
  }
}
