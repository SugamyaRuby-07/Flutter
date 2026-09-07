import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const OlympicApp());
}

class OlympicApp extends StatelessWidget {
  const OlympicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Olympic Rings Animation',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const OlympicPage(),
    );
  }
}

class OlympicPage extends StatefulWidget {
  const OlympicPage({super.key});

  @override
  State<OlympicPage> createState() => _OlympicPageState();
}

class _OlympicPageState extends State<OlympicPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void replayAnimation() {
    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title with Fade and Slide Animation
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final value = Curves.easeOut.transform(
                  (controller.value / 0.3).clamp(0.0, 1.0),
                );

                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -30 * (1 - value)),
                    child: const Text(
                      "OLYMPIC RINGS",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 45),

            // Olympic Rings
            SizedBox(
              width: 360,
              height: 210,
              child: Stack(
                children: [
                  // BLUE
                  Ring(
                    controller: controller,
                    color: const Color(0xFF0085C7),
                    left: 20,
                    top: 20,
                    start: 0.0,
                    end: 0.35,
                    slideOffset: const Offset(-120, 0),
                  ),

                  // BLACK
                  Ring(
                    controller: controller,
                    color: Colors.black,
                    left: 127,
                    top: 20,
                    start: 0.12,
                    end: 0.47,
                    slideOffset: const Offset(0, -100),
                  ),

                  // RED
                  Ring(
                    controller: controller,
                    color: const Color(0xFFDF0024),
                    left: 234,
                    top: 20,
                    start: 0.24,
                    end: 0.59,
                    slideOffset: const Offset(120, 0),
                  ),

                  // YELLOW
                  Ring(
                    controller: controller,
                    color: const Color(0xFFF4C300),
                    left: 73,
                    top: 90,
                    start: 0.36,
                    end: 0.71,
                    slideOffset: const Offset(-80, 100),
                  ),

                  // GREEN
                  Ring(
                    controller: controller,
                    color: const Color(0xFF009F3D),
                    left: 180,
                    top: 90,
                    start: 0.48,
                    end: 0.83,
                    slideOffset: const Offset(80, 100),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Subtitle with Fade Animation
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final value = ((controller.value - 0.7) / 0.3).clamp(0.0, 1.0);

                return Opacity(
                  opacity: Curves.easeIn.transform(value),
                  child: const Text(
                    "FASTER • HIGHER • STRONGER",
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: Colors.black54,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // Replay Button
            ElevatedButton.icon(
              onPressed: replayAnimation,
              icon: const Icon(Icons.replay),
              label: const Text("Replay Animation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Olympic Ring Widget
class Ring extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double left;
  final double top;
  final double start;
  final double end;
  final Offset slideOffset;

  const Ring({
    super.key,
    required this.controller,
    required this.color,
    required this.left,
    required this.top,
    required this.start,
    required this.end,
    required this.slideOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          // Calculate animation progress
          double progress;

          if (controller.value <= start) {
            progress = 0;
          } else if (controller.value >= end) {
            progress = 1;
          } else {
            progress = (controller.value - start) / (end - start);
          }

          progress = progress.clamp(0.0, 1.0);

          // Smooth animation
          final curvedProgress = Curves.easeOutBack.transform(progress);

          // FADE
          final opacity = progress;

          // SCALE
          final scale = 0.3 + (curvedProgress * 0.7);

          // SLIDE
          final slideX = slideOffset.dx * (1 - progress);

          final slideY = slideOffset.dy * (1 - progress);

          // ROTATION
          final rotation = (1 - progress) * pi / 2;

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(slideX, slideY),
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
