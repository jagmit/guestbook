import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/entities/guestbook.dart';

class FirebaseService {
  static Firestore _store = Firestore.instance;

  static String _kGuestbookCollection = "guestbook";

  static Future<List<GuestbookEntry>> fetchAllEntries() async {
    QuerySnapshot snapshot =
        await _store.collection(_kGuestbookCollection).orderBy('timestamp').getDocuments();
    var data = snapshot.documents
        .map(
          (DocumentSnapshot doc) => GuestbookEntry.fromFirestore(doc),
        )
        .toList();
    return data;
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
