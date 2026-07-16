import '../models/hidden_message.dart';

class MessageSeed {
  static List<HiddenMessage> get defaultMessages => [
        // --- SEASON 1 MESSAGES ---

        // Stage 2 (Small Plant) - Optional note for slow reveal
        HiddenMessage(
          stageRequired: 2,
          seasonNumber: 1,
          text: "A tiny seed is now a small green friend. Keep going, the journey has just begun!",
          imagePath: null, // Add local asset path here if desired (e.g. "assets/images/stage2.png")
          isRevealed: false,
        ),

        // Stage 3 (Budding) - Optional note for slow reveal
        HiddenMessage(
          stageRequired: 3,
          seasonNumber: 1,
          text: "A small bud is forming, full of promise. Just like your habits, growth is built day by day.",
          imagePath: null,
          isRevealed: false,
        ),

        // Stage 4 (Blooming) - Optional note for slow reveal
        HiddenMessage(
          stageRequired: 4,
          seasonNumber: 1,
          text: "Petals are starting to show. A gentle reminder that patience always bears beautiful results.",
          imagePath: null,
          isRevealed: false,
        ),

        // Stage 5 (Full Bloom) - Core Season 1 Message (User Editable)
        HiddenMessage(
          stageRequired: 5,
          seasonNumber: 1,
          text: "You did it! Your sprout has blossomed into a beautiful flower. Just like this plant, your daily habits have grown into something wonderful. I am so incredibly proud of you. Keep growing! 💖🌸🌱", // Edit this text directly before building the final APK
          imagePath: null, // Add local asset path here if desired (e.g. "assets/images/bloom.png")
          isRevealed: false,
        ),

        // --- ADD FUTURE SEASONS OR EXTRA STAGE REMINDERS HERE ---
      ];
}
