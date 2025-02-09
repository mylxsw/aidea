import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';

class RoleAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String? alternativeAvatarUrl;
  final String? name;
  final ChatHistory? his;
  final int avatarSize;

  const RoleAvatar({
    super.key,
    this.avatarUrl,
    this.alternativeAvatarUrl,
    this.his,
    this.name,
    this.avatarSize = 30,
  });

  @override
  State<RoleAvatar> createState() => _RoleAvatarState();
}

class _RoleAvatarState extends State<RoleAvatar> {
  @override
  Widget build(BuildContext context) {
    return _buildAvatar(context);
  }

  Widget _buildAvatar(BuildContext context) {
    if (widget.avatarUrl != null && widget.avatarUrl!.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(widget.avatarUrl!, qiniuImageTypeAvatar),
        size: widget.avatarSize,
      );
    }

    if (widget.alternativeAvatarUrl != null) {
      return RemoteAvatar(
        avatarUrl: imageURL(widget.alternativeAvatarUrl!, qiniuImageTypeAvatar),
        size: widget.avatarSize,
      );
    }

    if (widget.his != null && widget.his!.model != null) {
      return FutureBuilder(
        future: ModelAggregate.models(),
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            var mod = snapshot.data!.where((e) => e.id == widget.his!.model!).firstOrNull;
            if (mod != null && mod.avatarUrl != null && mod.avatarUrl != '') {
              return RemoteAvatar(avatarUrl: mod.avatarUrl!, size: widget.avatarSize);
            }
          }

          return LocalAvatar(assetName: 'assets/app.png', size: widget.avatarSize);
        },
      );
    }

    if (widget.name != null && widget.name!.isNotEmpty) {
      return Initicon(
        text: widget.name!.split('、').join(' '),
        size: widget.avatarSize.toDouble(),
        backgroundColor: Colors.grey.withAlpha(100),
        borderRadius: CustomSize.borderRadiusAll,
      );
    }

    return LocalAvatar(assetName: 'assets/app.png', size: widget.avatarSize);
  }
}
