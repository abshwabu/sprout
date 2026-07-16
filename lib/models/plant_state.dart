import 'package:hive/hive.dart';

part 'plant_state.g.dart';

@HiveType(typeId: 0)
class PlantState extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int stage; // 0=seed, 1=sprout, 2=small plant, 3=budding, 4=blooming, 5=full bloom

  @HiveField(2)
  final int totalWaters;

  @HiveField(3)
  final int currentStreak;

  @HiveField(4)
  final int longestStreak;

  @HiveField(5)
  final DateTime? lastWateredDate;

  @HiveField(6)
  final DateTime plantedDate;

  @HiveField(7)
  final int seasonNumber;

  PlantState({
    required this.id,
    required this.stage,
    required this.totalWaters,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWateredDate,
    required this.plantedDate,
    required this.seasonNumber,
  });

  PlantState copyWith({
    String? id,
    int? stage,
    int? totalWaters,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWateredDate,
    DateTime? plantedDate,
    int? seasonNumber,
  }) {
    return PlantState(
      id: id ?? this.id,
      stage: stage ?? this.stage,
      totalWaters: totalWaters ?? this.totalWaters,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWateredDate: lastWateredDate ?? this.lastWateredDate,
      plantedDate: plantedDate ?? this.plantedDate,
      seasonNumber: seasonNumber ?? this.seasonNumber,
    );
  }
}
