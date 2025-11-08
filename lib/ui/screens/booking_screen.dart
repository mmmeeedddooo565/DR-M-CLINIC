import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/appointment_service.dart';

class BookingScreen extends StatefulWidget {
  final String phone;
  const BookingScreen({super.key, required this.phone});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  String? _selectedVisitType; // كشف / إعادة / متابعة

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'حجز موعد' : 'Book appointment'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'اختر اليوم' : 'Select a day',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 14,
                  itemBuilder: (context, index) {
                    final day = DateTime.now().add(Duration(days: index + 1));
                    final closed = AppointmentService.isClosedDay(day);
                    final selected = day.year == _selectedDay.year &&
                        day.month == _selectedDay.month &&
                        day.day == _selectedDay.day;
                    return GestureDetector(
                      onTap: closed
                          ? null
                          : () {
                              setState(() => _selectedDay = day);
                            },
                      child: Container(
                        width: 64,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: closed
                              ? Colors.grey.shade300
                              : selected
                                  ? Colors.teal
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E', isAr ? 'ar' : 'en')
                                  .format(day),
                              style: TextStyle(
                                fontSize: 11,
                                color: closed || selected
                                    ? Colors.black
                                    : Colors.teal,
                              ),
                            ),
                            Text(
                              DateFormat('d').format(day),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: closed || selected
                                    ? Colors.black
                                    : Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAr ? 'نوع الزيارة' : 'Visit type',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildTypeChip(isAr ? 'كشف' : 'Consult', 'كشف'),
                  _buildTypeChip(isAr ? 'إعادة' : 'Revisit', 'إعادة'),
                  _buildTypeChip(isAr ? 'متابعة' : 'Follow-up', 'متابعة'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isAr ? 'المواعيد المتاحة' : 'Available slots',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: AppointmentService.buildSlotsForDay(_selectedDay),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final slots = snap.data!;
                    if (slots.isEmpty) {
                      return Center(
                        child: Text(isAr
                            ? 'لا توجد مواعيد متاحة'
                            : 'No available slots'),
                      );
                    }
                    return ListView.builder(
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final s = slots[index];
                        final left = s['left'] as int;
                        return Card(
                          child: ListTile(
                            title: Text(s['time'] as String),
                            subtitle: Text(
                              isAr
                                  ? 'متاح: $left من ${s['capacity']}'
                                  : 'Available: $left of ${s['capacity']}',
                            ),
                            trailing: FilledButton(
                              onPressed: left <= 0
                                  ? null
                                  : () async {
                                      if (_selectedVisitType == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(isAr
                                                ? 'اختر نوع الزيارة أولاً'
                                                : 'Select visit type first'),
                                          ),
                                        );
                                        return;
                                      }
                                      final dt = s['dateTime'] as DateTime;
                                      final ok =
                                          await AppointmentService.addBooking(
                                        phone: widget.phone,
                                        dt: dt,
                                        visitType: _selectedVisitType!,
                                        source: 'patient',
                                      );
                                      if (!mounted) return;
                                      if (!ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(isAr
                                                ? 'هذا الموعد ممتلئ'
                                                : 'This slot is full'),
                                          ),
                                        );
                                      } else {
                                        final txt =
                                            DateFormat('y/MM/dd HH:mm')
                                                .format(dt);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(isAr
                                                ? 'تم حجز الموعد: $txt'
                                                : 'Booked: $txt'),
                                          ),
                                        );
                                        setState(() {});
                                      }
                                    },
                              child: Text(isAr ? 'حجز' : 'Book'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final selected = _selectedVisitType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _selectedVisitType = value);
      },
    );
  }
}
