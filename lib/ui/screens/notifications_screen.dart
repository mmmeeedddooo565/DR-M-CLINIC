import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'الإشعارات' : 'Notifications'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: FirestoreService.getBroadcasts(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data!;
            if (data.isEmpty) {
              return Center(
                child: Text(
                    isAr ? 'لا توجد إشعارات بعد' : 'No notifications yet'),
              );
            }
            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = data[i];
                return ListTile(
                  leading: const Icon(Icons.campaign),
                  title: Text(m['msg'] ?? ''),
                  subtitle: Text(m['ts'] ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
