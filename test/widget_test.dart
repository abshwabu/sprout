import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sprout/screens/home_screen.dart';
import 'package:sprout/providers/plant_provider.dart';
import 'package:sprout/models/plant_state.dart';
import 'package:sprout/models/daily_log.dart';
import 'package:sprout/models/hidden_message.dart';

class FakePlantNotifier extends PlantNotifier {
  @override
  PlantState? build() {
    return PlantState(
      id: 'current_plant',
      stage: 0,
      totalWaters: 0,
      currentStreak: 0,
      longestStreak: 0,
      plantedDate: DateTime.now(),
      seasonNumber: 1,
    );
  }

  @override
  bool canWaterToday() => true;
}

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    Hive.registerAdapter(PlantStateAdapter());
    Hive.registerAdapter(DailyLogAdapter());
    Hive.registerAdapter(HiddenMessageAdapter());
    await Hive.openBox<PlantState>('plantStateBox');
    await Hive.openBox<DailyLog>('dailyLogBox');
    await Hive.openBox<HiddenMessage>('hiddenMessageBox');
    await Hive.openBox('settingsBox');
  });

  testWidgets('Sprout app home page title smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantProvider.overrideWith(() => FakePlantNotifier()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Let the initial frame render
    await tester.pump();

    // Verify that the title "Sprout" is displayed.
    expect(find.text('Sprout'), findsWidgets);
  });

  test('PlantNotifier streak reset and progress retention unit test', () async {
    // Seed initial state in Hive first so Notifier can load it
    final plantBox = Hive.box<PlantState>('plantStateBox');
    final initialState = PlantState(
      id: 'current_plant',
      stage: 0,
      totalWaters: 0,
      currentStreak: 0,
      longestStreak: 0,
      plantedDate: DateTime.now(),
      seasonNumber: 1,
    );
    await plantBox.put(initialState.id, initialState);

    final container = ProviderContainer();
    final notifier = container.read(plantProvider.notifier);

    // 1. Initial State Checks
    final initial = container.read(plantProvider);
    expect(initial, isNotNull);
    expect(initial!.totalWaters, 0);
    expect(initial.currentStreak, 0);
    expect(initial.stage, 0);

    // 2. Perform Water
    notifier.waterPlant();
    final stateAfterWater = container.read(plantProvider)!;
    expect(stateAfterWater.totalWaters, 1);
    expect(stateAfterWater.currentStreak, 1);
    expect(stateAfterWater.stage, 1); // 1 water reaches stage 1

    // 3. Simulate 3 Days Missed by setting lastWateredDate to 3 days ago
    final currentState = container.read(plantProvider)!;
    final stateWithMissedDays = currentState.copyWith(
      lastWateredDate: DateTime.now().subtract(const Duration(days: 3)),
      currentStreak: 5, // Set high streak to verify reset
    );
    
    // Update both Hive and notifier in-memory state
    await plantBox.put(stateWithMissedDays.id, stateWithMissedDays);
    notifier.state = stateWithMissedDays;

    // Trigger check for missed day (which happens on app open)
    notifier.checkForMissedDay();

    // 4. Verify Streak resets but growth progress is retained
    final finalState = container.read(plantProvider)!;
    expect(finalState.currentStreak, 0); // Streak resets to 0
    expect(finalState.totalWaters, 1);  // Progress remains intact
    expect(finalState.stage, 1);        // Stage remains intact
  });
}
