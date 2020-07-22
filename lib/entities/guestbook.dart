import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:guestbook/helper/date_helper.dart';
import 'package:guestbook/helper/resolve_required_key.dart';

class GuestbookEntry {
  final String entryId;

  final DateTime timestamp;

  final String name;

  final String message;

  GuestbookEntry({
    @required this.name,
    this.entryId,
    this.timestamp,
    @required this.message,
  });

  factory GuestbookEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    dynamic resolveKey = ResolveRequiredKey.getClosure(data);

    return GuestbookEntry(
      entryId: doc.documentID,
      timestamp: DateHelper.timeStampToDateTime(resolveKey("timestamp")),
      message: resolveKey("message"),
      name: resolveKey("name"),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": this.name,
      "message": this.message,
      "timestamp": Timestamp.fromDate(DateTime.now()),
    };
  }
}
