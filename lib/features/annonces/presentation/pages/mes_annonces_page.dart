import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/annonce_repository.dart';
import '../../models/annonce.dart';
import '../widgets/annonce_card.dart';

class MesAnnoncesPage extends StatelessWidget {
  const MesAnnoncesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repository = AnnonceRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes annonces'),
      ),
      body: userId.isEmpty
          ? Center(
              child: Text(
                'Vous devez être connecté',
                style: TextStyle(color: context.couleurs.onSurfaceVariant),
              ),
            )
          : StreamBuilder<List<Annonce>>(
              stream: repository.mesAnnonces(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur : ${snapshot.error}'),
                  );
                }

                final annonces = snapshot.data ?? [];

                if (annonces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 60,
                          color: context.couleurs.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune annonce pour le moment',
                          style: TextStyle(
                            color: context.couleurs.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

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
