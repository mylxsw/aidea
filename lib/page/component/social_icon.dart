import 'package:flutter/material.dart';

class SocialIcon extends StatelessWidget {
  final String image;
  final String name;
  final Function? onTap;
  const SocialIcon({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Column(
        children: [
          Image.asset(image, width: 30),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }
}
