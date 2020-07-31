import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/entities/guestbook.dart';

class FirebaseService {
  static Firestore _store = Firestore.instance;

  static String _kGuestbookCollection = "guestbook";

  static Future<List<GuestbookEntry>> fetchAllEntries() async {
    QuerySnapshot snapshot = await _store
        .collection(_kGuestbookCollection)
        .orderBy('timestamp')
        .getDocuments();
    var data = snapshot.documents
        .map(
          (DocumentSnapshot doc) => GuestbookEntry.fromFirestore(doc),
        )
        .toList();
    return data;
  }

  static Stream<List<GuestbookEntry>> listenToEntries() {
    return _store.collection(_kGuestbookCollection).snapshots().map(
          (QuerySnapshot snapshot) => snapshot.documents
              .map(
                (DocumentSnapshot doc) => GuestbookEntry.fromFirestore(doc),
              )
              .toList()
                ..sort(
                  // newest timestamps first
                  (a, b) => -(a.timestamp.compareTo(b.timestamp)),
                ),
        );
  }

  static Future<String> createEntry(GuestbookEntry entry) {
    return _store
        .collection(_kGuestbookCollection)
        .add(
          entry.toFirestore(),
        )
        .then((ref) => ref.documentID);
  }
}
