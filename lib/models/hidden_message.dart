import 'package:hive/hive.dart';

part 'hidden_message.g.dart';

@HiveType(typeId: 2)
class HiddenMessage extends HiveObject {
  @HiveField(0)
  final int stageRequired;

  @HiveField(1)
  final int seasonNumber;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final String? imagePath;

  @HiveField(4)
  bool isRevealed;

  @HiveField(5)
  DateTime? dateUnlocked;

  HiddenMessage({
    required this.stageRequired,
    required this.seasonNumber,
    required this.text,
    this.imagePath,
    this.isRevealed = false,
    this.dateUnlocked,
  });

  HiddenMessage copyWith({
    int? stageRequired,
    int? seasonNumber,
    String? text,
    String? imagePath,
    bool? isRevealed,
    DateTime? dateUnlocked,
  }) {
    return HiddenMessage(
      stageRequired: stageRequired ?? this.stageRequired,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      isRevealed: isRevealed ?? this.isRevealed,
      dateUnlocked: dateUnlocked ?? this.dateUnlocked,
    );
  }
}
