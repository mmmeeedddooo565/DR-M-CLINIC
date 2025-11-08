import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'booking_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'followups_screen.dart';

class HomeScreen extends StatefulWidget {
  final String phone;
  const HomeScreen({super.key, required this.phone});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    final pages = [
      BookingScreen(phone: widget.phone),
      const NotificationsScreen(),
      ProfileScreen(phone: widget.phone),
      FollowupsScreen(phone: widget.phone),
    ];
    final labelsAr = ['حجز', 'إشعارات', 'بيانات', 'متابعات'];
    final labelsEn = ['Book', 'Notifications', 'Profile', 'Follow-ups'];

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_month),
              label: isAr ? labelsAr[0] : labelsEn[0],
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications),
              label: isAr ? labelsAr[1] : labelsEn[1],
            ),
            NavigationDestination(
              icon: const Icon(Icons.person),
              label: isAr ? labelsAr[2] : labelsEn[2],
            ),
            NavigationDestination(
              icon: const Icon(Icons.list_alt),
              label: isAr ? labelsAr[3] : labelsEn[3],
            ),
          ],
        ),
      ),
    );
  }
}
