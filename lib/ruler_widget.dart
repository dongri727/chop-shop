import 'package:flutter/material.dart';

class RulerWidget extends StatefulWidget {
  const RulerWidget({Key? key}) : super(key: key);

  @override
  State<RulerWidget> createState() => _RulerWidgetState();
}

class _RulerWidgetState extends State<RulerWidget>{

  double sliderValue = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Ruler Test')),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Center(
              child: CustomPaint(
                painter: RulerPainter(
                  sliderValue: sliderValue,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
              child: Slider(
                value: sliderValue,
                divisions: 90,
                min: 100,
                max: 1000,
                label: sliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ))
        ],
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  static const double height = 500;
  static const double width = 30;
  static const double lineWidth = 1;
  static const Color lineColor = Colors.grey;
  static const double markerHeight = 10;
  static const double markerWidth = 5;

  final double sliderValue;


  RulerPainter({required this.sliderValue});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final double distanceBetweenLines = height / sliderValue;
    double startX = size.height;
    double startY = size.width - width;

    for (int i = 0; i <= sliderValue; i++) {
      if (i % 10 == 0) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(startX + width, startY),
          linePaint,
        );

        textPainter.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(startX - markerWidth - 2, startY - markerHeight / 2),
        );
      } else if (i % 5 == 0) {
        canvas.drawLine(
          Offset(startX + width / 2, startY),
          Offset(startX + width / 2, startY - markerHeight / 2),
          linePaint,
        );
      } else {
        canvas.drawLine(
          Offset(startX + width / 2, startY),
          Offset(startX + width / 2, startY - markerHeight / 4),
          linePaint,
        );
      }

      startY -= distanceBetweenLines;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}