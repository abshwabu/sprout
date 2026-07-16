import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sprout/main.dart';
import 'package:sprout/providers/plant_provider.dart';
import 'package:sprout/models/plant_state.dart';

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
    await Hive.openBox('settingsBox');
  });

  testWidgets('Sprout app home page title smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantProvider.overrideWith(() => FakePlantNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    // Let the animations/layout settle
    await tester.pumpAndSettle();

    // Verify that the title "Sprout" is displayed.
    expect(find.text('Sprout'), findsWidgets);
  });
}
