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

  Future<void> supprimerAnnonce(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
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
