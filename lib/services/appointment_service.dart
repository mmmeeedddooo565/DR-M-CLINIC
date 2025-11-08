import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_paths.dart';
import 'firestore_service.dart';

class AppointmentService {
  static const List<String> defaultSlots = ['16:30', '17:30', '18:30'];
  static const int defaultCapacity = 2;

  static bool isClosedDay(DateTime d) {
    // الاثنين والجمعة إجازة
    return d.weekday == DateTime.monday || d.weekday == DateTime.friday;
  }

  static Future<Map<String, dynamic>> getConfig() async {
    final docRef = FirestoreService.settingsCol.doc('config');
    final snap = await docRef.get();
    final data = snap.data() ?? {};
    return {
      'slots': List<String>.from(data['slots'] ?? defaultSlots),
      'capacity': (data['capacity'] ?? defaultCapacity) as int,
    };
  }

  static Future<void> saveConfig({
    required List<String> slots,
    required int capacity,
  }) async {
    await FirestoreService.settingsCol.doc('config').set({
      'slots': slots,
      'capacity': capacity,
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> buildSlotsForDay(
      DateTime day) async {
    final cfg = await getConfig();
    final slots = List<String>.from(cfg['slots']);
    final capacity = cfg['capacity'] as int;

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snap = await FirestoreService.appointmentsCol
        .where('dateTime', isGreaterThanOrEqualTo: start)
        .where('dateTime', isLessThan: end)
        .get();

    final counts = <String, int>{};
    for (final d in snap.docs) {
      final dt = (d.data()['dateTime'] as Timestamp).toDate();
      final key =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return slots.map((time) {
      final parts = time.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final dt = DateTime(day.year, day.month, day.day, h, m);
      final used = counts[time] ?? 0;
      final left = capacity - used;
      return {
        'time': time,
        'dateTime': dt,
        'used': used,
        'left': left < 0 ? 0 : left,
        'capacity': capacity,
      };
    }).toList();
  }

  static Future<bool> addBooking({
    required String phone,
    required DateTime dt,
    required String visitType,
    required String source, // patient / secretary / admin
  }) async {
    final cfg = await getConfig();
    final capacity = cfg['capacity'] as int;

    final start = DateTime(dt.year, dt.month, dt.day);
    final end = start.add(const Duration(days: 1));

    final snap = await FirestoreService.appointmentsCol
        .where('dateTime', isGreaterThanOrEqualTo: start)
        .where('dateTime', isLessThan: end)
        .get();

    int used = 0;
    for (final d in snap.docs) {
      final x = (d.data()['dateTime'] as Timestamp).toDate();
      if (x.hour == dt.hour && x.minute == dt.minute) {
        used++;
      }
    }

    if (used >= capacity) return false;

    final id = '${dt.toIso8601String()}_${phone}_$source';
    await FirestoreService.appointmentsCol.doc(id).set({
      'phone': phone,
      'dateTime': dt,
      'visitType': visitType,
      'source': source,
      'status': 'booked',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
  }
}
