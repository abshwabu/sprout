import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../providers/plant_provider.dart';
import '../models/plant_state.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const Map<int, String> _stageNames = {
    0: 'Seed',
    1: 'Sprout',
    2: 'Small Plant',
    3: 'Budding',
    4: 'Blooming',
    5: 'Full Bloom',
  };

  static const Map<int, String> _stageDescriptions = {
    0: 'A tiny seed sleeping in the warm soil.',
    1: 'A tiny green leaf is breaking through!',
    2: 'Getting stronger and taller every day.',
    3: 'A small bud is forming at the top.',
    4: 'The colors are starting to show!',
    5: 'A beautiful flower in full, glorious bloom!',
  };

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _dropletController;
  late AnimationController _plantController;
  late Animation<double> _dropletY;
  late Animation<double> _dropletOpacity;
  late Animation<double> _plantScale;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _dropletController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Droplet falls from above the plant (-40) to hit the center pot/stem area (100)
    _dropletY = Tween<double>(begin: -40.0, end: 100.0).animate(
      CurvedAnimation(parent: _dropletController, curve: Curves.easeInQuad),
    );

    _dropletOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_dropletController);

    _plantController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _plantScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.95).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_plantController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermissionOnLaunch();
    });
  }

  @override
  void dispose() {
    _dropletController.dispose();
    _plantController.dispose();
    super.dispose();
  }

  String _getProgressText(int totalWaters) {
    if (totalWaters < 1) return '0 / 1 water to Sprout';
    if (totalWaters < 4) return '$totalWaters / 4 waters to Small Plant';
    if (totalWaters < 9) return '$totalWaters / 9 waters to Budding';
    if (totalWaters < 16) return '$totalWaters / 16 waters to Blooming';
    if (totalWaters < 25) return '$totalWaters / 25 waters to Full Bloom';
    return 'Fully grown! Great job! 🎉';
  }

  double _getProgressPercentage(int totalWaters) {
    if (totalWaters < 1) return totalWaters / 1.0;
    if (totalWaters < 4) return totalWaters / 4.0;
    if (totalWaters < 9) return totalWaters / 9.0;
    if (totalWaters < 16) return totalWaters / 16.0;
    if (totalWaters < 25) return totalWaters / 25.0;
    return 1.0;
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Season?'),
        content: const Text(
          'This will reset your plant to a seed and start a new season. Your lifetime longest streak and log history will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(plantProvider.notifier).startNewSeason();
              Navigator.pop(context);
            },
            child: const Text('Start New Season'),
          ),
        ],
      ),
    );
  }

  void _showGrowthMessage(int newStage) {
    final stageName = HomeScreen._stageNames[newStage] ?? 'New Stage';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E7D32), // Dark green
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFFD54F)), // Golden sparkle
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '✨ Grew a stage! Your plant is now a $stageName! 🎉',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onWaterTap() async {
    final plantState = ref.read(plantProvider);
    if (plantState == null) return;

    // Trigger haptic feedback (light impact)
    await HapticFeedback.lightImpact();

    setState(() {
      _isAnimating = true;
    });

    // Start droplet falling animation
    _dropletController.forward(from: 0.0).then((_) {
      // Once droplet hits the plant, trigger the plant bounce/wiggle animation
      _plantController.forward(from: 0.0).then((_) {
        setState(() {
          _isAnimating = false;
        });
      });

      // Perform watering business logic
      final oldStage = plantState.stage;
      ref.read(plantProvider.notifier).waterPlant();
      
      final updatedState = ref.read(plantProvider);
      if (updatedState != null && updatedState.stage > oldStage) {
        _showGrowthMessage(updatedState.stage);
      }
    });
  }

  void _checkNotificationPermissionOnLaunch() async {
    final settingsBox = Hive.box('settingsBox');
    final hasAsked = settingsBox.get('permission_asked', defaultValue: false);
    if (!hasAsked) {
      _showPermissionExplainerDialog(settingsBox);
    }
  }

  void _showPermissionExplainerDialog(Box settingsBox) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF5B8266)),
            SizedBox(width: 12),
            Text('Daily Reminders'),
          ],
        ),
        content: const Text(
          'Want a gentle daily reminder to water your plant? We will notify you when it is ready for some love.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              settingsBox.put('permission_asked', true);
              settingsBox.put('reminders_enabled', false);
              NotificationService.cancelDailyReminder();
              Navigator.pop(context);
            },
            child: const Text('No Thanks'),
          ),
          FilledButton(
            onPressed: () async {
              settingsBox.put('permission_asked', true);
              final granted = await NotificationService.requestPermissions();
              settingsBox.put('reminders_enabled', granted);
              if (granted) {
                final hour = settingsBox.get('reminder_hour', defaultValue: 18);
                final minute = settingsBox.get('reminder_minute', defaultValue: 0);
                await NotificationService.scheduleDailyReminder(hour, minute);
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Enable Reminders'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider);

    if (plantState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final canWater = ref.read(plantProvider.notifier).canWaterToday();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sprout',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Start New Season',
            icon: const Icon(Icons.autorenew),
            onPressed: () => _showResetConfirmation(context),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Season Info
                  Chip(
                    label: Text(
                      'Season ${plantState.seasonNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 16),

                  // Plant Stage Title & Description
                  Text(
                    HomeScreen._stageNames[plantState.stage] ?? 'Seed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E35),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    HomeScreen._stageDescriptions[plantState.stage] ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5C7264),
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Center: Plant Illustration (Custom Painted) & Animated Droplet
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Plant Illustration with scale animation
                        ScaleTransition(
                          scale: _plantScale,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey<int>(plantState.stage),
                              child: SizedBox(
                                width: 200,
                                height: 200,
                                child: CustomPaint(
                                  painter: PlantPainter(plantState.stage),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Falling Water Droplet
                        AnimatedBuilder(
                          animation: _dropletController,
                          builder: (context, child) {
                            if (!_isAnimating) return const SizedBox.shrink();
                            return Positioned(
                              top: _dropletY.value,
                              child: Opacity(
                                opacity: _dropletOpacity.value,
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Color(0xFF2196F3),
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Streak Badge
                  if (plantState.currentStreak > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${plantState.currentStreak} Day Streak',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Growth Progress Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Growth Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _getProgressText(plantState.totalWaters),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5C7264),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _getProgressPercentage(plantState.totalWaters),
                            minHeight: 10,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom: Action Button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: canWater
                        ? Column(
                            key: const ValueKey('water_button'),
                            children: [
                              ElevatedButton(
                                onPressed: _isAnimating ? null : _onWaterTap,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(24),
                                  backgroundColor: const Color(0xFF64B5F6),
                                  foregroundColor: Colors.white,
                                  shadowColor: const Color(0xFF64B5F6).withOpacity(0.4),
                                  elevation: 6,
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap to Water',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E35),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            key: const ValueKey('watered_today'),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFC8E6C9),
                                width: 1.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Watered today 🌱 come back tomorrow',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw beautiful procedural plants representing the 6 growth stages.
class PlantPainter extends CustomPainter {
  final int stage;
  PlantPainter(this.stage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final bottomY = size.height - 20; // Leave space for soil mound/pot

    // 1. Draw a cute pastel pot
    paint.color = const Color(0xFFE5DCD5); // Sand / warm grey pot
    final potPath = Path()
      ..moveTo(centerX - 45, bottomY)
      ..lineTo(centerX + 45, bottomY)
      ..lineTo(centerX + 35, bottomY - 35)
      ..lineTo(centerX - 35, bottomY - 35)
      ..close();
    canvas.drawPath(potPath, paint);

    // Draw the rim of the pot
    paint.color = const Color(0xFFD6CBC3);
    final rimRect = Rect.fromLTRB(centerX - 39, bottomY - 40, centerX + 39, bottomY - 35);
    canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(4)), paint);

    // 2. Draw Soil
    paint.color = const Color(0xFF795548); // Brown soil
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, bottomY - 37), width: 66, height: 10),
      paint,
    );

    // 3. Draw Plant Growth Stages
    if (stage == 0) {
      // Stage 0: Seed
      paint.color = const Color(0xFF8D6E63); // Seed brown
      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX - 2, bottomY - 42), width: 12, height: 8),
        paint,
      );
      paint.color = const Color(0xFFD7CCC8); // Seed highlighting
      canvas.drawCircle(Offset(centerX - 4, bottomY - 43), 2, paint);
    } else if (stage == 1) {
      // Stage 1: Sprout
      paint.color = const Color(0xFF81C784); // Bright green stem
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      final stemPath = Path()
        ..moveTo(centerX, bottomY - 38)
        ..quadraticBezierTo(centerX + 8, bottomY - 55, centerX - 4, bottomY - 65);
      canvas.drawPath(stemPath, paint);

      // Draw leaf
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF66BB6A);
      final leafPath = Path()
        ..moveTo(centerX - 4, bottomY - 65)
        ..quadraticBezierTo(centerX - 16, bottomY - 70, centerX - 12, bottomY - 55)
        ..quadraticBezierTo(centerX - 4, bottomY - 56, centerX - 4, bottomY - 65);
      canvas.drawPath(leafPath, paint);
    } else if (stage == 2) {
      // Stage 2: Small Plant
      paint.color = const Color(0xFF81C784);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;
      final stemPath = Path()
        ..moveTo(centerX, bottomY - 38)
        ..quadraticBezierTo(centerX - 12, bottomY - 68, centerX, bottomY - 95);
      canvas.drawPath(stemPath, paint);

      // Leaf left
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF66BB6A);
      final leafLeft = Path()
        ..moveTo(centerX - 6, bottomY - 65)
        ..quadraticBezierTo(centerX - 26, bottomY - 72, centerX - 20, bottomY - 52)
        ..quadraticBezierTo(centerX - 6, bottomY - 55, centerX - 6, bottomY - 65);
      canvas.drawPath(leafLeft, paint);

      // Leaf right
      paint.color = const Color(0xFF4CAF50);
      final leafRight = Path()
        ..moveTo(centerX - 2, bottomY - 80)
        ..quadraticBezierTo(centerX + 18, bottomY - 88, centerX + 15, bottomY - 68)
        ..quadraticBezierTo(centerX - 2, bottomY - 72, centerX - 2, bottomY - 80);
      canvas.drawPath(leafRight, paint);
    } else if (stage == 3) {
      // Stage 3: Budding
      // Stem
      paint.color = const Color(0xFF81C784);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 5;
      final stemPath = Path()
        ..moveTo(centerX, bottomY - 38)
        ..quadraticBezierTo(centerX + 15, bottomY - 85, centerX - 2, bottomY - 125);
      canvas.drawPath(stemPath, paint);

      // Leaves
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF4CAF50);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX - 18, bottomY - 70), width: 24, height: 12),
        paint,
      );
      paint.color = const Color(0xFF388E3C);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX + 20, bottomY - 95), width: 24, height: 12),
        paint,
      );

      // Bud base
      paint.color = const Color(0xFF81C784);
      canvas.drawCircle(Offset(centerX - 2, bottomY - 126), 6, paint);

      // Flower Bud
      paint.color = const Color(0xFFEC407A); // Pink bud
      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX - 2, bottomY - 134), width: 14, height: 18),
        paint,
      );
    } else if (stage == 4) {
      // Stage 4: Blooming
      // Stem
      paint.color = const Color(0xFF81C784);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 5;
      final stemPath = Path()
        ..moveTo(centerX, bottomY - 38)
        ..quadraticBezierTo(centerX - 15, bottomY - 90, centerX, bottomY - 140);
      canvas.drawPath(stemPath, paint);

      // Leaves
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF4CAF50);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 22, bottomY - 75), width: 26, height: 14), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX + 22, bottomY - 105), width: 26, height: 14), paint);

      // Petals (half-open)
      paint.color = const Color(0xFFF48FB1); // Pastel pink
      canvas.drawCircle(Offset(centerX - 10, bottomY - 145), 12, paint);
      canvas.drawCircle(Offset(centerX + 10, bottomY - 145), 12, paint);
      canvas.drawCircle(Offset(centerX, bottomY - 157), 12, paint);

      // Center
      paint.color = const Color(0xFFFFEE58); // Yellow
      canvas.drawCircle(Offset(centerX, bottomY - 144), 9, paint);
    } else if (stage == 5) {
      // Stage 5: Full Bloom
      // Stem
      paint.color = const Color(0xFF66BB6A);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 6;
      final stemPath = Path()
        ..moveTo(centerX, bottomY - 38)
        ..quadraticBezierTo(centerX, bottomY - 100, centerX, bottomY - 150);
      canvas.drawPath(stemPath, paint);

      // Leaves
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF388E3C); // Darker lush green
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 26, bottomY - 70), width: 32, height: 16), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX + 26, bottomY - 95), width: 32, height: 16), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 20, bottomY - 125), width: 26, height: 14), paint);

      // Flower petals (Full bloom circular flower)
      paint.color = const Color(0xFFEC407A); // Vibrant pink
      final double flowerY = bottomY - 155;
      const double radius = 14;
      canvas.drawCircle(Offset(centerX, flowerY - 16), radius, paint);
      canvas.drawCircle(Offset(centerX, flowerY + 16), radius, paint);
      canvas.drawCircle(Offset(centerX - 16, flowerY), radius, paint);
      canvas.drawCircle(Offset(centerX + 16, flowerY), radius, paint);
      canvas.drawCircle(Offset(centerX - 11, flowerY - 11), radius, paint);
      canvas.drawCircle(Offset(centerX + 11, flowerY - 11), radius, paint);
      canvas.drawCircle(Offset(centerX - 11, flowerY + 11), radius, paint);
      canvas.drawCircle(Offset(centerX + 11, flowerY + 11), radius, paint);

      // Flower Center
      paint.color = const Color(0xFFFFD54F); // Vibrant yellow center
      canvas.drawCircle(Offset(centerX, flowerY), 13, paint);

      // Inner details
      paint.color = const Color(0xFFE65100);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;
      canvas.drawCircle(Offset(centerX, flowerY), 7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlantPainter oldDelegate) {
    return oldDelegate.stage != stage;
  }
}
