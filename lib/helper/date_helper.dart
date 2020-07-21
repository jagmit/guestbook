import 'package:cloud_firestore/cloud_firestore.dart';

class DateHelper {
  static DateTime timeStampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }
}
