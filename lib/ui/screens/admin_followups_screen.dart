import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../core/firebase_paths.dart';
import '../../services/firestore_service.dart';

class AdminFollowupsScreen extends StatefulWidget {
  const AdminFollowupsScreen({super.key});

  @override
  State<AdminFollowupsScreen> createState() => _AdminFollowupsScreenState();
}

class _AdminFollowupsScreenState extends State<AdminFollowupsScreen> {
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selected =
      DateTime.now().add(const Duration(days: 7));

  Future<void> _addFollowup() async {
    final isAr = context.read<LanguageService>().isArabic;
    final phone = _phoneCtrl.text.trim();
    final note = _noteCtrl.text.trim();
    if (phone.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? 'أدخل رقم الموبايل والملاحظة'
              : 'Enter phone & note'),
        ),
      );
      return;
    }
    await FirestoreService.followupsCol.add({
      'phone': phone,
      'note': note,
      'dt': _selected,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _noteCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isAr ? 'تم إضافة متابعة' : 'Follow-up added'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr
              ? 'جدول المتابعات'
              : 'Follow-ups table'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: isAr
                          ? 'رقم الموبايل'
                          : 'Phone',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      labelText: isAr
                          ? 'ملاحظة'
                          : 'Note',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        DateFormat('y/MM/dd HH:mm')
                            .format(_selected),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selected,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (d == null) return;
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _selected),
                          );
                          if (t == null) return;
                          setState(() {
                            _selected = DateTime(
                              d.year,
                              d.month,
                              d.day,
                              t.hour,
                              t.minute,
                            );
                          });
                        },
                        child: Text(isAr
                            ? 'تغيير الموعد'
                            : 'Change time'),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _addFollowup,
                      child: Text(isAr
                          ? 'إضافة متابعة'
                          : 'Add follow-up'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirestoreService.followupsStream(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(isAr
                          ? 'لا توجد متابعات'
                          : 'No follow-ups'),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = docs[i].data();
                      final dt =
                          (m['dt'] as Timestamp).toDate();
                      final phone = m['phone'] ?? '';
                      final note = m['note'] ?? '';
                      return ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(
                            '$phone - ${DateFormat('y/MM/dd HH:mm').format(dt)}'),
                        subtitle: Text(note),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
