import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../core/firebase_paths.dart';

class FollowupsScreen extends StatelessWidget {
  final String phone;
  const FollowupsScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'مواعيد المتابعات' : 'Follow-ups'),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(FbCollections.followups)
              .where('phone', isEqualTo: phone)
              .orderBy('dt')
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Text(isAr
                    ? 'لا توجد مواعيد متابعة'
                    : 'No follow-ups'),
              );
            }
            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = docs[i].data();
                final dt = (m['dt'] as Timestamp).toDate();
                return ListTile(
                  leading: const Icon(Icons.event_note),
                  title: Text(
                    DateFormat('y/MM/dd HH:mm').format(dt),
                  ),
                  subtitle: Text(m['note'] ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
