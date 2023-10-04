import 'package:flutter/material.dart';

class GradientStyle {
  static LinearGradient warmLinear() {
    return const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      stops: [0.0, 0.5, 1.0],
      colors: [
        Color.fromARGB(255, 245, 205, 93),
        Color.fromARGB(255, 234, 146, 75),
        Color.fromARGB(255, 211, 89, 61),
      ],
    );
  }

  static LinearGradient coldLinear() {
    return const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      stops: [0.0, 0.5, 1.0],
      colors: [
        Color.fromARGB(255, 82, 181, 208),
        Color.fromARGB(255, 66, 133, 191),
        Color.fromARGB(255, 66, 87, 177),
      ],
    );
  }

  static LinearGradient greenLinear() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 1.0],
      colors: [
        Color.fromARGB(200, 68, 255, 0),
        Color.fromARGB(200, 131, 220, 99),
      ],
    );
  }

  static LinearGradient whiteLinear() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 1.0],
      colors: [
        Color.fromARGB(200, 255, 255, 255),
        Color.fromARGB(200, 224, 224, 224),
      ],
    );
  }
}
