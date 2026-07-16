import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to HomeScreen after 2.5 seconds with a smooth fade-out
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vector flower motif
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _SplashMotifPainter(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sprout',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C3E35),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'grow at your own pace',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5C7264),
                      fontSize: 14,
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

class _SplashMotifPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw Leaves
    paint.color = const Color(0xFF81C784);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 20, centerY + 10), width: 35, height: 18),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 20, centerY + 10), width: 35, height: 18),
      paint,
    );

    // Draw Flower Petals
    paint.color = const Color(0xFFEC407A); // Pink
    const double petalOffset = 18;
    canvas.drawCircle(Offset(centerX, centerY - petalOffset), 12, paint);
    canvas.drawCircle(Offset(centerX, centerY + petalOffset), 12, paint);
    canvas.drawCircle(Offset(centerX - petalOffset, centerY), 12, paint);
    canvas.drawCircle(Offset(centerX + petalOffset, centerY), 12, paint);

    // Center
    paint.color = const Color(0xFFFFD54F); // Yellow
    canvas.drawCircle(Offset(centerX, centerY), 10, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
