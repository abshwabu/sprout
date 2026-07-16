import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/plant_provider.dart';
import '../models/plant_state.dart';
import '../models/hidden_message.dart';
import '../models/daily_log.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantState = ref.watch(plantProvider);

    if (plantState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Garden History',
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Streak Stats
                _buildStatsCard(context, plantState),
                const SizedBox(height: 24),

                // 2. Calendar View
                _buildCalendar(context, plantState),
                const SizedBox(height: 24),

                // 3. Unlocked Messages Header
                Text(
                  'Unlocked Secrets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E35),
                      ),
                ),
                const SizedBox(height: 12),

                // 4. Unlocked Messages List
                _buildUnlockedMessagesList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, PlantState plantState) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  '${plantState.currentStreak} days',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E35),
                      ),
                ),
                const Text(
                  'Current Streak',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey.shade300,
            ),
            Column(
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  '${plantState.longestStreak} days',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E35),
                      ),
                ),
                const Text(
                  'Longest Streak',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, PlantState plantState) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final totalDays = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 for Sunday, 1 for Monday...

    final days = <Widget>[];

    // Weekday headers: S, M, T, W, T, F, S
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (final day in weekdays) {
      days.add(
        Center(
          child: Text(
            day,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // Empty spaces before the 1st of the month
    for (int i = 0; i < startWeekday; i++) {
      days.add(const SizedBox.shrink());
    }

    // Days of the month
    final logBox = Hive.box<DailyLog>('dailyLogBox');
    final planted = plantState.plantedDate;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(now.year, now.month, day);
      final isFuture = date.isAfter(todayDate);
      final isBeforePlanted = date.isBefore(DateTime(planted.year, planted.month, planted.day));

      bool isWatered = false;
      bool isMissed = false;

      if (!isFuture && !isBeforePlanted) {
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final log = logBox.get(key);
        if (log != null && log.watered) {
          isWatered = true;
        } else {
          if (date.isBefore(todayDate)) {
            isMissed = true;
          }
        }
      }

      Widget dayContent;
      if (isWatered) {
        dayContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            const CircleAvatar(radius: 4, backgroundColor: Colors.green),
          ],
        );
      } else if (isMissed) {
        dayContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 2),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
            ),
          ],
        );
      } else {
        // Future or before planted or today and not watered yet
        dayContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: TextStyle(color: isFuture ? Colors.grey.shade300 : Colors.black87, fontSize: 13)),
            const SizedBox(height: 2),
            const SizedBox(height: 8), // Placeholder spacer
          ],
        );
      }

      days.add(
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: date.year == today.year && date.month == today.month && date.day == today.day
                ? Colors.green.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: dayContent,
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(now),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E35)),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              children: days,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedMessagesList(BuildContext context) {
    return ValueListenableBuilder<Box<HiddenMessage>>(
      valueListenable: Hive.box<HiddenMessage>('hiddenMessageBox').listenable(),
      builder: (context, box, _) {
        final revealedMessages = box.values.where((msg) => msg.isRevealed).toList();

        // Sort chronologically (earliest to latest based on dateUnlocked, or fallback to stage)
        revealedMessages.sort((a, b) {
          if (a.dateUnlocked != null && b.dateUnlocked != null) {
            return a.dateUnlocked!.compareTo(b.dateUnlocked!);
          }
          return a.stageRequired.compareTo(b.stageRequired);
        });

        if (revealedMessages.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No secrets unlocked yet this season. Keep watering your plant to discover them! 🌸',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5C7264),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: revealedMessages.length,
          itemBuilder: (context, index) {
            final message = revealedMessages[index];
            final dateStr = message.dateUnlocked != null
                ? dateFormat.format(message.dateUnlocked!)
                : 'Unlocked';

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Season ${message.seasonNumber} • Stage ${message.stageRequired}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E35),
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (message.imagePath != null && message.imagePath!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          message.imagePath!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
