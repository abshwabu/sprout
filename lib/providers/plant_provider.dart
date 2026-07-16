import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/plant_state.dart';
import '../models/daily_log.dart';
import '../models/hidden_message.dart';

class PlantNotifier extends Notifier<PlantState?> {
  // Thresholds for stage advancement (feel achievable within about a month)
  static const int stage1WaterThreshold = 1;  // Sprout
  static const int stage2WaterThreshold = 4;  // Small plant
  static const int stage3WaterThreshold = 9;  // Budding
  static const int stage4WaterThreshold = 16; // Blooming
  static const int stage5WaterThreshold = 25; // Full bloom

  @override
  PlantState? build() {
    final plantBox = Hive.box<PlantState>('plantStateBox');
    final current = plantBox.get('current_plant');
    
    if (current != null) {
      final lastWatered = current.lastWateredDate;
      if (lastWatered != null) {
        final now = DateTime.now();
        final difference = _daysBetween(lastWatered, now);
        if (difference > 1 && current.currentStreak > 0) {
          final updatedState = current.copyWith(currentStreak: 0);
          plantBox.put('current_plant', updatedState);
          return updatedState;
        }
      }
    }
    return current;
  }

  Box<PlantState> get _plantBox => Hive.box<PlantState>('plantStateBox');
  Box<DailyLog> get _logBox => Hive.box<DailyLog>('dailyLogBox');

  /// Calculates the growth stage based on the total number of waterings.
  int _calculateStage(int totalWaters) {
    if (totalWaters >= stage5WaterThreshold) return 5;
    if (totalWaters >= stage4WaterThreshold) return 4;
    if (totalWaters >= stage3WaterThreshold) return 3;
    if (totalWaters >= stage2WaterThreshold) return 2;
    if (totalWaters >= stage1WaterThreshold) return 1;
    return 0;
  }

  /// Format date key for DailyLog Map (e.g., "2026-07-16")
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper to calculate the difference in calendar days between two dates.
  int _daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Checks if the plant can be watered today.
  bool canWaterToday() {
    final current = state;
    if (current == null) return false;
    final lastWatered = current.lastWateredDate;
    if (lastWatered == null) return true;

    final now = DateTime.now();
    return lastWatered.year != now.year ||
        lastWatered.month != now.month ||
        lastWatered.day != now.day;
  }

  /// Waters the plant, incrementing watering metrics and advancing growth stage if thresholds are met.
  void waterPlant() {
    final current = state;
    if (current == null || !canWaterToday()) return;

    final now = DateTime.now();
    final lastWatered = current.lastWateredDate;

    int newStreak = 1;
    if (lastWatered != null) {
      final difference = _daysBetween(lastWatered, now);
      if (difference == 1) {
        newStreak = current.currentStreak + 1;
      } else if (difference == 0) {
        newStreak = current.currentStreak;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final newLongest = newStreak > current.longestStreak ? newStreak : current.longestStreak;
    final newTotalWaters = current.totalWaters + 1;
    final newStage = _calculateStage(newTotalWaters);

    final updatedState = current.copyWith(
      totalWaters: newTotalWaters,
      stage: newStage,
      lastWateredDate: now,
      currentStreak: newStreak,
      longestStreak: newLongest,
    );

    state = updatedState;
    _plantBox.put('current_plant', updatedState);

    // Write DailyLog
    final logKey = _formatDateKey(now);
    final logEntry = DailyLog(
      date: now,
      watered: true,
      noteUnlocked: 'Watered on day $newTotalWaters of season ${current.seasonNumber}!',
    );
    _logBox.put(logKey, logEntry);
  }

  /// Checks for missed days. Breaks current streak if more than 1 day was missed.
  void checkForMissedDay() {
    final current = state;
    if (current == null) return;
    final lastWatered = current.lastWateredDate;
    if (lastWatered == null) return;

    final now = DateTime.now();
    final difference = _daysBetween(lastWatered, now);
    if (difference > 1) {
      if (current.currentStreak > 0) {
        final updatedState = current.copyWith(currentStreak: 0);
        state = updatedState;
        _plantBox.put('current_plant', updatedState);
      }
    }
  }

  /// Starts a new growth season, resetting stage, totalWaters, and currentStreak to 0.
  void startNewSeason() {
    final current = state;
    if (current == null) return;

    final updatedState = PlantState(
      id: 'current_plant',
      stage: 0,
      totalWaters: 0,
      currentStreak: 0,
      longestStreak: current.longestStreak,
      plantedDate: DateTime.now(),
      seasonNumber: current.seasonNumber + 1,
    );

    state = updatedState;
    _plantBox.put('current_plant', updatedState);
  }

  /// Retrieves a hidden message for the specified stage and season, if not yet revealed.
  HiddenMessage? getHiddenMessageFor(int stage, int season) {
    final box = Hive.box<HiddenMessage>('hiddenMessageBox');
    for (final msg in box.values) {
      if (msg.stageRequired == stage && msg.seasonNumber == season && !msg.isRevealed) {
        return msg;
      }
    }
    return null;
  }

  /// Marks a hidden message as revealed.
  void markMessageAsRevealed(HiddenMessage message) {
    message.isRevealed = true;
    message.dateUnlocked = DateTime.now();
    message.save();
  }
}

final plantProvider = NotifierProvider<PlantNotifier, PlantState?>(() {
  return PlantNotifier();
});
