import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/appointment_service.dart';
import 'admin_users_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_followups_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final AdminRole? role;
  const AdminHomeScreen({super.key, this.role});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late AdminRole _role;
  final _patientPhone = TextEditingController();
  final _manualPass = TextEditingController();
  final _broadcast = TextEditingController();

  bool get isSecretary => _role == AdminRole.secretary;

  @override
  void initState() {
    super.initState();
    _role = widget.role ?? AdminRole.admin;
  }

  Future<void> _setPassword() async {
    final isAr = context.read<LanguageService>().isArabic;
    final phone = _patientPhone.text.trim();
    final pass = _manualPass.text.trim();
    if (phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? 'أدخل رقم الموبايل وكلمة المرور'
              : 'Enter phone & password'),
        ),
      );
      return;
    }
    await AuthService.setUserPassword(phone, pass);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAr
            ? 'تم حفظ كلمة المرور للمستخدم'
            : 'Password saved for user'),
      ),
    );
  }

  Future<void> _postBroadcast() async {
    final msg = _broadcast.text.trim();
    if (msg.isEmpty) return;
    await FirestoreService.addBroadcast(msg);
    _broadcast.clear();
    final isAr = context.read<LanguageService>().isArabic;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isAr ? 'تم إرسال الإشعار' : 'Broadcast sent'),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _todaySummary() async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    return await AppointmentService.buildSlotsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isSecretary
                ? (isAr
                    ? 'لوحة السكرتيرة'
                    : 'Secretary Dashboard')
                : (isAr
                    ? 'لوحة الأدمن'
                    : 'Admin Dashboard'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: isAr ? 'المستخدمون' : 'Users',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: isAr ? 'الحجوزات' : 'Bookings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminBookingsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.event_note),
              tooltip: isAr ? 'متابعات' : 'Follow-ups',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminFollowupsScreen(),
                  ),
                );
              },
            ),
            if (!isSecretary)
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: isAr ? 'إعدادات' : 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSettingsScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _todaySummary(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    );
                  }
                  final slots = snap.data!;
                  final total =
                      slots.fold<int>(0, (p, e) => p + (e['used'] as int));
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr
                                ? 'موجز حجوزات اليوم'
                                : "Today's bookings summary",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (isAr
                                    ? 'إجمالي الحجوزات: '
                                    : 'Total bookings: ') +
                                total.toString(),
                          ),
                          const SizedBox(height: 4),
                          ...slots.map((s) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(s['time'] as String),
                                  Text(
                                    isAr
                                        ? 'محجوز: ${s['used']}/${s['capacity']}'
                                        : 'Booked: ${s['used']}/${s['capacity']}',
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                isAr
                    ? 'تعيين كلمة مرور لمستخدم'
                    : 'Set user password',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _patientPhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isAr
                      ? 'رقم موبايل المستخدم'
                      : 'User phone',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _manualPass,
                decoration: InputDecoration(
                  labelText: isAr
                      ? 'كلمة المرور'
                      : 'Password',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _setPassword,
                child: Text(
                  isAr
                      ? 'حفظ كلمة المرور'
                      : 'Save password',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAr
                    ? 'إشعار عام لكل المستخدمين'
                    : 'Broadcast message',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _broadcast,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isAr
                      ? 'اكتب رسالة قصيرة تظهر في الإشعارات داخل التطبيق'
                      : 'Write a short in-app notification',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _postBroadcast,
                icon: const Icon(Icons.campaign),
                label: Text(
                  isAr ? 'إرسال' : 'Send',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
