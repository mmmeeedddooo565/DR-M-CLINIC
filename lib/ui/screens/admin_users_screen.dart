import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'المستخدمون' : 'Users'),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirestoreService.usersStream(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Text(isAr
                    ? 'لا يوجد مستخدمون بعد'
                    : 'No users yet'),
              );
            }
            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = docs[i].data();
                final phone = u['phone'] ?? '';
                final name = u['name'] ?? '';
                final pass = u['password'] ?? '';
                final age = u['age']?.toString() ?? '';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('$phone${name != '' ? ' - $name' : ''}'),
                  subtitle: Text(
                    (isAr ? 'كلمة المرور: ' : 'Password: ') +
                        (pass.toString()),
                  ),
                  trailing: Text(age),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
