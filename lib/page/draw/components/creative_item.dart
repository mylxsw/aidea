import 'package:askaide/page/component/image.dart';
import 'package:flutter/material.dart';

class CreativeItem extends StatelessWidget {
  final String imageURL;
  final String title;
  final Color? titleColor;
  final Function() onTap;
  const CreativeItem({
    super.key,
    required this.imageURL,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImageEnhanced(
                    imageUrl: imageURL,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 20,
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
