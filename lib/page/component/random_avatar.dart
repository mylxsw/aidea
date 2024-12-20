import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart' as ava;

enum AvatarUsage {
  room,
  user,
  legacy,
}

class RandomAvatar extends StatelessWidget {
  final int id;
  final int? size;
  final AvatarUsage usage;
  final BorderRadiusGeometry? borderRadius;
  const RandomAvatar({
    super.key,
    required this.id,
    this.size,
    required this.usage,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == AvatarUsage.user || usage == AvatarUsage.legacy) {
      return ava.RandomAvatar(
        '$id',
        width: size?.toDouble(),
        height: size?.toDouble(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size?.toDouble() ?? 500,
        maxHeight: size?.toDouble() ?? 500,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? CustomSize.borderRadius,
        child: CachedNetworkImage(
          imageUrl: 'https://ai-api.aicode.cc/v1/images/random-avatar/${usage.name}/$id/${size ?? 500}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class RemoteAvatar extends StatelessWidget {
  final String avatarUrl;
  final int? size;
  final double? radius;
  const RemoteAvatar({super.key, required this.avatarUrl, this.size, this.radius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.toDouble() ?? 60,
      height: size?.toDouble() ?? 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? CustomSize.radiusValue),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class LocalAvatar extends StatelessWidget {
  final String assetName;
  final int? size;
  const LocalAvatar({super.key, required this.assetName, this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.toDouble() ?? 60,
      height: size?.toDouble() ?? 60,
      child: ClipRRect(borderRadius: CustomSize.borderRadius, child: Image.asset(assetName, fit: BoxFit.fill)),
    );
  }
}
