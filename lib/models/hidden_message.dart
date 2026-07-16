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

  HiddenMessage({
    required this.stageRequired,
    required this.seasonNumber,
    required this.text,
    this.imagePath,
  });

  HiddenMessage copyWith({
    int? stageRequired,
    int? seasonNumber,
    String? text,
    String? imagePath,
  }) {
    return HiddenMessage(
      stageRequired: stageRequired ?? this.stageRequired,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
