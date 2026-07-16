import 'package:hive/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 1)
class DailyLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final bool watered;

  @HiveField(2)
  final String? noteUnlocked;

  DailyLog({
    required this.date,
    required this.watered,
    this.noteUnlocked,
  });

  DailyLog copyWith({
    DateTime? date,
    bool? watered,
    String? noteUnlocked,
  }) {
    return DailyLog(
      date: date ?? this.date,
      watered: watered ?? this.watered,
      noteUnlocked: noteUnlocked ?? this.noteUnlocked,
    );
  }
}
