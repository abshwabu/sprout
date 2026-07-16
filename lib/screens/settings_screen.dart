import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import 'memories_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;
  bool _remindersEnabled = true;
  int _reminderHour = 18;
  int _reminderMinute = 0;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settingsBox');
    _remindersEnabled = _settingsBox.get('reminders_enabled', defaultValue: true);
    _reminderHour = _settingsBox.get('reminder_hour', defaultValue: 18);
    _reminderMinute = _settingsBox.get('reminder_minute', defaultValue: 0);
  }

  String _formatTime(int hour, int minute) {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat.jm().format(time); // Format to local time format (e.g. 6:00 PM)
  }

  void _toggleReminders(bool value) async {
    if (value) {
      final granted = await NotificationService.requestPermissions();
      if (granted) {
        setState(() {
          _remindersEnabled = true;
        });
        _settingsBox.put('reminders_enabled', true);
        await NotificationService.scheduleDailyReminder(_reminderHour, _reminderMinute);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permissions were denied. Please enable them in system settings.'),
            ),
          );
        }
      }
    } else {
      setState(() {
        _remindersEnabled = false;
      });
      _settingsBox.put('reminders_enabled', false);
      await NotificationService.cancelDailyReminder();
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF5B8266),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
      _settingsBox.put('reminder_hour', picked.hour);
      _settingsBox.put('reminder_minute', picked.minute);
      await NotificationService.scheduleDailyReminder(picked.hour, picked.minute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${_formatTime(picked.hour, picked.minute)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // Soft Mint Green
              Color(0xFFFFFDE7), // Soft Cream Yellow
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Card(
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Gentle Reminder',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Send a sweet reminder to check on my sprout'),
                    value: _remindersEnabled,
                    onChanged: _toggleReminders,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  if (_remindersEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text(
                        'Reminder Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_formatTime(_reminderHour, _reminderMinute)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectTime,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Garden Memories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Read your collection of unlocked notes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const MemoriesScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
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
