import 'dart:ui';

import 'package:flutter/material.dart';

class GlassEffect extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const GlassEffect({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20.0,
          sigmaY: 20.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.black26,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.25,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: Colors.black12,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
