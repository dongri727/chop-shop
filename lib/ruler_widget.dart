import 'package:flutter/material.dart';

class RulerWidget extends StatefulWidget {
  const RulerWidget({super.key});

  @override
  State<RulerWidget> createState() => _RulerWidgetState();
}

class _RulerWidgetState extends State<RulerWidget>{

  double currentSliderValue = 50;
  //final double height;
  //final double width;
  final double lineWidth = 1;
  final Color lineColor = Colors.grey;

/*  const RulerWidget({super.key,
    this.count = 100,
    //this.height = 200,
    //this.width = 50,
    this.lineWidth = 1,
    this.lineColor = Colors.grey,
  });*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Ruler Test')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: CustomPaint(
              painter: RulerPainter(
                currentSliderValue: currentSliderValue,
                lineWidth: lineWidth,
                lineColor: lineColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
              child: Slider(
                value: currentSliderValue,
                divisions: 9,
                min: 10,
                max: 100,
                label: currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    currentSliderValue = value;
                  });
                },
              ))
        ],
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  double currentSliderValue;
  final double lineWidth;
  final Color lineColor;

  RulerPainter({
    this.currentSliderValue = 0,
    this.lineWidth = 1,
    this.lineColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    double distanceBetweenLines = size.height / currentSliderValue;
    double startX = 0.0;
    double startY = 0.0;

    for (int i = 0; i <= currentSliderValue; i++) {
      Offset start = Offset(startX, startY);
      Offset end = Offset(startX + size.width, startY);
      canvas.drawLine(start, end, linePaint);

      startY += distanceBetweenLines;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}