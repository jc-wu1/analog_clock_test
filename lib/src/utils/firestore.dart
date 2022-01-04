import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Storage {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const collection = 'alarm';

  static Stream<QuerySnapshot> getStream() {
    return firestore.collection(collection).snapshots();
  }

  static void deleteAlarm(String id) {
    firestore
        .collection(collection)
        .doc(id)
        .delete()
        .then((value) => debugPrint("Alarm deleted"))
        .catchError((error) => debugPrint("failed to delete alarm"));
  }

  static void disableAlarm(String id, bool isActive) {
    firestore
        .collection(collection)
        .doc(id)
        .update({'active': isActive})
        .then((value) => debugPrint("Alarm changed"))
        .catchError((error) => debugPrint("failed to delete alarm"));
  }

  static Future<String> addAlarm(alarm) async {
    return await firestore.collection(collection).add(alarm).then((value) {
      debugPrint("Alarm added successfully");
      return value.id;
    });
  }

  static Future<DocumentSnapshot> getAlarmDetails(String id) async {
    return await firestore.collection(collection).doc(id).get();
  }

  static void updateAlarm(String id, alarm) async {
    await firestore.collection(collection).doc(id).update(alarm);
  }
}
