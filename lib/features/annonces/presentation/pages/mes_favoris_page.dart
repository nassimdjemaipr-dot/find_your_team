import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/stockage/favoris_service.dart';
import '../../data/annonce_repository.dart';
import '../../models/annonce.dart';
import '../widgets/annonce_card.dart';

class MesFavorisPage extends StatelessWidget {
  const MesFavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AnnonceRepository();
    final favorisIds = FavorisService.obtenirTous();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
      ),
      body: favorisIds.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 60,
                    color: context.couleurs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun favori pour le moment',
                    style: TextStyle(
                      color: context.couleurs.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<Annonce>>(
              stream: repository.annoncesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur : ${snapshot.error}'),
                  );
                }

                final toutesAnnonces = snapshot.data ?? [];
                final annonces = toutesAnnonces
                    .where((a) => favorisIds.contains(a.id))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: annonces.length,
                  itemBuilder: (context, index) {
                    return AnnonceCard(annonce: annonces[index]);
                  },
                );
              },
            ),
    );
  }
}
