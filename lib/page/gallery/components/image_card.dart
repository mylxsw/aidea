import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final List<String> images;
  final String? username;
  final int? userId;
  final int hotValue;
  final Function()? onTap;
  const ImageCard({
    super.key,
    required this.images,
    this.username,
    this.userId,
    this.hotValue = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: customColors.columnBlockBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 50,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: images.isEmpty
                    ? Image.asset('assets/image-broken.png')
                    : CachedNetworkImageEnhanced(
                        imageUrl:
                            imageURL(images.first, qiniuImageTypeThumbMedium),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RandomAvatar(
                        id: userId ?? 0,
                        size: 15,
                        usage: AvatarUsage.user,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        username ?? '匿名',
                        style: TextStyle(
                          color: customColors.weakTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: hotValue > 0 ? Colors.amber : null,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$hotValue',
                        style: TextStyle(
                          color: customColors.weakTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
