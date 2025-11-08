import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'كل الحجوزات' : 'All bookings'),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirestoreService.appointmentsStream(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Text(isAr
                    ? 'لا توجد حجوزات بعد'
                    : 'No bookings yet'),
              );
            }
            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = docs[i].data();
                final dt = (m['dateTime'] as Timestamp).toDate();
                final phone = m['phone'] ?? '';
                final visitType = m['visitType'] ?? '';
                final source = m['source'] ?? '';
                final timeStr =
                    DateFormat('y/MM/dd HH:mm').format(dt);
                return ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('$timeStr - $phone'),
                  subtitle: Text(
                    (isAr ? 'نوع الزيارة: ' : 'Type: ') +
                        visitType +
                        (isAr ? ' - حجز بواسطة: ' : ' - By: ') +
                        source,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
