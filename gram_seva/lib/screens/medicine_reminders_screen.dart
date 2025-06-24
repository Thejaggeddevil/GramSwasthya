import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicineReminder {
  final String medicine;
  final TimeOfDay time;
  MedicineReminder({required this.medicine, required this.time});

  Map<String, dynamic> toJson() => {
    'medicine': medicine,
    'hour': time.hour,
    'minute': time.minute,
  };

  factory MedicineReminder.fromJson(Map<String, dynamic> json) =>
      MedicineReminder(
        medicine: json['medicine'],
        time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      );
}

class MedicineRemindersScreen extends StatefulWidget {
  const MedicineRemindersScreen({Key? key}) : super(key: key);

  @override
  State<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState extends State<MedicineRemindersScreen> {
  final List<MedicineReminder> _reminders = [];
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadReminders();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _notifications.initialize(initSettings);
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList('medicine_reminders');
    if (data != null) {
      setState(() {
        _reminders.clear();
        _reminders.addAll(
          data.map(
            (e) => MedicineReminder.fromJson(
              Map<String, dynamic>.from(jsonDecode(e)),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _reminders.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('medicine_reminders', data);
  }

  Future<void> _scheduleNotification(int id, MedicineReminder reminder) async {
    final now = TimeOfDay.now();
    final today = DateTime.now();
    final scheduledDate = DateTime(
      today.year,
      today.month,
      today.day,
      reminder.time.hour,
      reminder.time.minute,
    );
    final tzScheduled = tz.TZDateTime.from(
      scheduledDate.isBefore(DateTime.now())
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate,
      tz.local,
    );
    await _notifications.zonedSchedule(
      id,
      'medicine_reminders'.tr(),
      reminder.medicine,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminders_channel',
          'Medicine Reminders',
          channelDescription: 'Reminders for taking medicine',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  void _addOrEditReminder({int? editIndex}) async {
    final medicineController = TextEditingController(
      text: editIndex != null ? _reminders[editIndex].medicine : '',
    );
    TimeOfDay? selectedTime =
        editIndex != null ? _reminders[editIndex].time : null;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              editIndex == null ? 'add_reminder'.tr() : 'Edit Reminder',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: medicineController,
                  decoration: InputDecoration(
                    hintText: 'enter_medicine_and_time'.tr(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      selectedTime == null
                          ? 'Select Time'
                          : selectedTime?.format(context) ?? '',
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: const Icon(Icons.access_time),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  if (medicineController.text.trim().isNotEmpty &&
                      selectedTime != null) {
                    Navigator.pop(context, {
                      'medicine': medicineController.text.trim(),
                      'time': selectedTime,
                    });
                  }
                },
                child: Text(editIndex == null ? 'add'.tr() : 'Save'),
              ),
            ],
          ),
    );
    if (result != null) {
      final medicine = result['medicine'] as String;
      final time = result['time'] as TimeOfDay;
      setState(() {
        if (editIndex != null) {
          _reminders[editIndex] = MedicineReminder(
            medicine: medicine,
            time: time,
          );
        } else {
          _reminders.add(MedicineReminder(medicine: medicine, time: time));
        }
      });
      await _saveReminders();
      await _scheduleNotification(
        editIndex ?? _reminders.length - 1,
        MedicineReminder(medicine: medicine, time: time),
      );
    }
  }

  void _deleteReminder(int index) async {
    setState(() {
      _reminders.removeAt(index);
    });
    await _saveReminders();
    await _cancelNotification(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('medicine_reminders'.tr()),
        backgroundColor: const Color(0xFF43AA8B),
      ),
      body:
          _reminders.isEmpty
              ? Center(child: Text('no_reminders_yet'.tr()))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder.medicine + index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteReminder(index),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(
                          Icons.medication,
                          color: Color(0xFF43AA8B),
                        ),
                        title: Text(reminder.medicine),
                        subtitle: Text(
                          'Time: ' + reminder.time.format(context),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => _addOrEditReminder(editIndex: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteReminder(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditReminder(),
        backgroundColor: const Color(0xFF43AA8B),
        child: const Icon(Icons.add),
        tooltip: 'add_reminder'.tr(),
      ),
    );
  }
}
