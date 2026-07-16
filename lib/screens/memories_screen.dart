import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hidden_message.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Garden Memories',
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
              Color(0xFFE8F5E9), // Mint Green
              Color(0xFFFFFDE7), // Soft Cream Yellow
            ],
          ),
        ),
        child: ValueListenableBuilder<Box<HiddenMessage>>(
          valueListenable: Hive.box<HiddenMessage>('hiddenMessageBox').listenable(),
          builder: (context, box, _) {
            // Retrieve only messages that have been unlocked (isRevealed = true)
            final revealedMessages = box.values.where((msg) => msg.isRevealed).toList();

            if (revealedMessages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Secrets Still Sleeping',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E35),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep watering your plant day by day to unlock secret memories and messages! 🌿',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF5C7264),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: revealedMessages.length,
              itemBuilder: (context, index) {
                final message = revealedMessages[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(
                                'Season ${message.seasonNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              side: BorderSide.none,
                            ),
                            Text(
                              'Stage ${message.stageRequired} Reward',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E35),
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (message.imagePath != null && message.imagePath!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              message.imagePath!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink(); // Hide if asset doesn't exist
                              },
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
        ),
      ),
    );
  }
}
