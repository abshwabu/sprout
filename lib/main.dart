import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/plant_state.dart';
import 'models/daily_log.dart';
import 'models/hidden_message.dart';
import 'services/notification_service.dart';
import 'services/message_seed.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(PlantStateAdapter());
  Hive.registerAdapter(DailyLogAdapter());
  Hive.registerAdapter(HiddenMessageAdapter());
  
  // Open Hive boxes
  await Hive.openBox<PlantState>('plantStateBox');
  await Hive.openBox<DailyLog>('dailyLogBox');
  await Hive.openBox<HiddenMessage>('hiddenMessageBox');
  final settingsBox = await Hive.openBox('settingsBox');

  // Initialize Notifications
  await NotificationService.init();

  // Seed initial PlantState
  _seedInitialPlantState();
  
  // Seed initial HiddenMessages
  _seedHiddenMessages();

  // Schedule default reminder on startup if enabled
  if (settingsBox.get('reminders_enabled', defaultValue: true)) {
    final hour = settingsBox.get('reminder_hour', defaultValue: 18);
    final minute = settingsBox.get('reminder_minute', defaultValue: 0);
    NotificationService.scheduleDailyReminder(hour, minute);
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

void _seedHiddenMessages() {
  final box = Hive.box<HiddenMessage>('hiddenMessageBox');
  if (box.isEmpty) {
    box.addAll(MessageSeed.defaultMessages);
  }
}

void _seedInitialPlantState() {
  final box = Hive.box<PlantState>('plantStateBox');
  if (box.isEmpty) {
    final initialState = PlantState(
      id: 'current_plant',
      stage: 0,
      totalWaters: 0,
      currentStreak: 0,
      longestStreak: 0,
      plantedDate: DateTime.now(),
      seasonNumber: 1,
    );
    box.put(initialState.id, initialState);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprout',
      theme: SproutTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
