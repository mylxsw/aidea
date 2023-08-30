import 'dart:async';

import 'package:flutter/material.dart';

class Cursor extends CustomPainter {
  final Color? color;

  const Cursor({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color ?? Colors.black;
    canvas.drawCircle(const Offset(0, 10), 3.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedCursor extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;

  const AnimatedCursor({
    super.key,
    this.width = 2,
    this.height = 20,
    this.color,
  });

  @override
  State<AnimatedCursor> createState() => _AnimatedCursorState();
}

class _AnimatedCursorState extends State<AnimatedCursor>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  bool _showCursor = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showCursor
        ? CustomPaint(
            size: Size(widget.width, widget.height),
            painter: Cursor(color: widget.color),
          )
        : SizedBox(width: widget.width, height: widget.height);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
