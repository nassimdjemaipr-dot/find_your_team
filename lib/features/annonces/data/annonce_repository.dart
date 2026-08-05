import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/annonce.dart';

class AnnonceRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'annonces';

  AnnonceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Annonce>> annoncesStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Annonce.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<String> ajouterAnnonce(Annonce annonce) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(annonce.toMap());
    return docRef.id;
  }

  Future<void> modifierAnnonce(String id, Annonce annonce) async {
    await _firestore.collection(_collection).doc(id).update(annonce.toMap());
  }

  Future<void> supprimerAnnonce(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Change uniquement le statut d'une annonce.
  // On n'envoie que ce champ a Firestore, pas toute l'annonce :
  // c'est plus rapide et ca evite d'ecraser par erreur une autre
  // modification faite entre-temps.
  Future<void> changerStatut(String id, String statut) async {
    await _firestore.collection(_collection).doc(id).update({'statut': statut});
  }

  Stream<List<Annonce>> mesAnnonces(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Annonce.fromMap(doc.id, doc.data()))
            .toList());
  }
}
