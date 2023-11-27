import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/prompt_tags_selector.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class CreativeItem extends StatelessWidget {
  final String imageURL;
  final String title;
  final Color? titleColor;
  final String? tag;
  final Function() onTap;
  final String size;
  const CreativeItem({
    super.key,
    required this.imageURL,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.tag,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImageEnhanced(
                  imageUrl: imageURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (size == 'large')
              Positioned(
                left: 20,
                top: 20,
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (tag != null && tag != '')
                      Tag(
                        name: tag!,
                        backgroundColor: customColors.linkColor,
                        fontsize: 10,
                      ),
                  ],
                ),
              )
            else if (size == 'medium')
              Positioned(
                left: 20,
                top: 25,
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (tag != null && tag != '')
                      ScaleTransition(
                        scale: const AlwaysStoppedAnimation(0.5),
                        child: Tag(
                          name: tag!,
                          backgroundColor: customColors.linkColor,
                          fontsize: 10,
                        ),
                      ),
                  ],
                ),
              )
            else
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tag != null && tag != '') const SizedBox(width: 20),
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    if (tag != null && tag != '')
                      ScaleTransition(
                        scale: const AlwaysStoppedAnimation(0.5),
                        child: Tag(
                          name: tag!,
                          backgroundColor: customColors.linkColor,
                          fontsize: 10,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
