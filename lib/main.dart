// In-Class Activity 06 - Drawing with Flutter
// Student: Jihun Kim
// Date: September 30, 2026

import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmileyApp());
}

enum FaceType { classic, sleepy, surprised }

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  final Random random = Random();

  double mood = 0.8;
  FaceType faceType = FaceType.classic;
  Color? randomColor;

  String get faceName {
    switch (faceType) {
      case FaceType.classic:
        return 'Classic';
      case FaceType.sleepy:
        return 'Sleepy';
      case FaceType.surprised:
        return 'Surprised';
    }
  }

  String get moodName {
    if (mood < 0.35) {
      return 'Sad';
    } else if (mood <= 0.7) {
      return 'Neutral';
    } else {
      return 'Happy';
    }
  }

  Color get faceColor {
    if (randomColor != null) {
      return randomColor!;
    }

    if (mood < 0.35) {
      return Colors.lightBlue.shade300;
    } else if (mood <= 0.7) {
      return Colors.yellow.shade600;
    } else {
      return Colors.orange.shade300;
    }
  }

  void showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void selectFace(FaceType value) {
    setState(() {
      faceType = value;
    });

    showMessage('Face changed to $faceName');
  }

  void cycleFace() {
    final nextIndex = (faceType.index + 1) % FaceType.values.length;
    selectFace(FaceType.values[nextIndex]);
  }

  void randomizeFace() {
    const colors = [
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.amber,
      Colors.lightGreen,
      Colors.deepOrangeAccent,
      Colors.purpleAccent,
    ];

    setState(() {
      mood = random.nextDouble();
      randomColor = colors[random.nextInt(colors.length)];
    });

    showMessage(
      'Random mood: ${mood.toStringAsFixed(2)}. Face color changed!',
    );
  }

  void resetFace() {
    setState(() {
      mood = 0.8;
      faceType = FaceType.classic;
      randomColor = null;
    });

    showMessage('Face reset');
  }

  Widget buildDrawing() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final drawingSize = min(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: cycleFace,
            onLongPress: randomizeFace,
            child: CustomPaint(
              size: Size(drawingSize, drawingSize),
              painter: SmileyPainter(
                mood: mood,
                faceColor: faceColor,
                faceType: faceType,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$faceName Face',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mood: $moodName (${mood.toStringAsFixed(2)})',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: mood,
            min: 0,
            max: 1,
            divisions: 100,
            label: mood.toStringAsFixed(2),
            onChanged: (value) {
              setState(() {
                mood = value;

                // Return to mood-based colors when the slider moves.
                randomColor = null;
              });
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sad'),
              Text('Neutral'),
              Text('Happy'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Classic'),
                selected: faceType == FaceType.classic,
                onSelected: (_) => selectFace(FaceType.classic),
              ),
              ChoiceChip(
                label: const Text('Sleepy'),
                selected: faceType == FaceType.sleepy,
                onSelected: (_) => selectFace(FaceType.sleepy),
              ),
              ChoiceChip(
                label: const Text('Surprised'),
                selected: faceType == FaceType.surprised,
                onSelected: (_) => selectFace(FaceType.surprised),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the face to switch designs.\n'
            'Long-press the face to randomize mood and color.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: resetFace,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smiley Painter Lab'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                constraints.maxWidth > constraints.maxHeight;

            if (isLandscape) {
              return Row(
                children: [
                  Expanded(child: buildDrawing()),
                  Expanded(child: buildControls()),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: buildDrawing()),
                Flexible(child: buildControls()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceColor,
    required this.faceType,
  });

  final double mood;
  final Color faceColor;
  final FaceType faceType;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.4;

    // Scale line widths with the face.
    final lineWidth = radius * 0.035;

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final eyePaint = Paint()..color = Colors.black87;

    final strokePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Draw the face first so it does not cover the eyes or mouth.
    canvas.drawCircle(center, radius, facePaint);
    canvas.drawCircle(center, radius, borderPaint);

    final eyeY = center.dy - radius * 0.22;
    final eyeDx = radius * 0.35;
    final leftEye = Offset(center.dx - eyeDx, eyeY);
    final rightEye = Offset(center.dx + eyeDx, eyeY);

    // Each design has different eyes.
    if (faceType == FaceType.sleepy) {
      for (final eye in [leftEye, rightEye]) {
        final eyeRect = Rect.fromCenter(
          center: eye,
          width: radius * 0.28,
          height: radius * 0.16,
        );

        canvas.drawArc(
          eyeRect,
          0,
          pi,
          false,
          strokePaint,
        );
      }
    } else {
      final eyeRadius = faceType == FaceType.surprised
          ? radius * 0.13
          : radius * 0.09;

      canvas.drawCircle(leftEye, eyeRadius, eyePaint);
      canvas.drawCircle(rightEye, eyeRadius, eyePaint);

      // Small white highlights.
      final highlightPaint = Paint()..color = Colors.white;

      for (final eye in [leftEye, rightEye]) {
        canvas.drawCircle(
          eye + Offset(-eyeRadius * 0.25, -eyeRadius * 0.25),
          eyeRadius * 0.3,
          highlightPaint,
        );
      }
    }

    // Mouth position and size are based on the face radius.
    if (faceType == FaceType.surprised) {
      final mouthRect = Rect.fromCenter(
        center: center + Offset(0, radius * 0.4),
        width: radius * 0.3,
        height: radius * (0.3 + mood * 0.2),
      );

      canvas.drawOval(mouthRect, eyePaint);
    } else {
      final isSad = mood < 0.35;
      final isHappy = mood > 0.7;

      double mouthHeight;

      if (isSad) {
        mouthHeight = radius * (0.3 + (0.35 - mood) * 0.6);
      } else if (isHappy) {
        mouthHeight = radius * (0.55 + (mood - 0.7) * 0.8);
      } else {
        mouthHeight = radius * (0.12 + (mood - 0.35) * 0.6);
      }

      // Sleepy faces use a softer mouth curve.
      if (faceType == FaceType.sleepy) {
        mouthHeight *= 0.5;
      }

      final mouthRect = Rect.fromCenter(
        center: center + Offset(0, radius * 0.3),
        width: radius * 0.95,
        height: mouthHeight,
      );

      canvas.drawArc(
        mouthRect,
        isSad ? 1.15 * pi : 0.15 * pi,
        0.70 * pi,
        false,
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.faceType != faceType;
  }
}