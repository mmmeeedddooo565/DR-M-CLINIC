import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_paths.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // USERS
  static CollectionReference<Map<String, dynamic>> get usersCol =>
      _db.collection(FbCollections.users);

  static Future<void> upsertUser({
    required String phone,
    String? password,
    String? name,
    int? age,
  }) async {
    await usersCol.doc(phone).set({
      'phone': phone,
      if (password != null && password.isNotEmpty) 'password': password,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUser(String phone) async {
    final doc = await usersCol.doc(phone).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  static Future<void> deleteUser(String phone) async {
    await usersCol.doc(phone).delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return usersCol.orderBy('phone').snapshots();
  }

  // BROADCASTS
  static CollectionReference<Map<String, dynamic>> get broadcastsCol =>
      _db.collection(FbCollections.broadcasts);

  static Future<void> addBroadcast(String msg) async {
    await broadcastsCol.add({
      'msg': msg,
      'ts': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getBroadcasts() async {
    final snap =
        await broadcastsCol.orderBy('ts', descending: true).get();
    return snap.docs
        .map((d) => {
              'id': d.id,
              'msg': d.data()['msg'] ?? '',
              'ts': (d.data()['ts'] ?? '').toString(),
            })
        .toList();
  }

  // APPOINTMENTS
  static CollectionReference<Map<String, dynamic>> get appointmentsCol =>
      _db.collection(FbCollections.appointments);

  static Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsStream() {
    return appointmentsCol.orderBy('dateTime').snapshots();
  }

  // FOLLOWUPS
  static CollectionReference<Map<String, dynamic>> get followupsCol =>
      _db.collection(FbCollections.followups);

  static Stream<QuerySnapshot<Map<String, dynamic>>> followupsStream() {
    return followupsCol.orderBy('dt').snapshots();
  }

  // SETTINGS
  static CollectionReference<Map<String, dynamic>> get settingsCol =>
      _db.collection(FbCollections.settings);
}
