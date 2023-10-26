import 'dart:io';

import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum AvatarType {
  localFile,
  network,
  random,
}

class Avatar {
  final AvatarType type;
  final String? url;
  final int? id;

  const Avatar({
    required this.type,
    this.url,
    this.id,
  });
}

class AvatarSelector extends StatefulWidget {
  final Function(Avatar selected) onSelected;
  final int randomSeed;

  final int? defaultAvatarId;
  final String? defaultAvatarUrl;

  final List<int> externalAvatarIds;
  final List<String> externalAvatarUrls;

  final AvatarUsage usage;

  const AvatarSelector({
    super.key,
    required this.onSelected,
    required this.randomSeed,
    this.defaultAvatarId,
    this.defaultAvatarUrl,
    required this.usage,
    this.externalAvatarIds = const [],
    this.externalAvatarUrls = const [],
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  String? _avatarUrl;
  int? _avatarId;

  @override
  void initState() {
    super.initState();
    _avatarId = widget.defaultAvatarId;
    _avatarUrl = widget.defaultAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_avatarUrl != null)
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _avatarUrl!.startsWith('http')
                      ? CachedNetworkImageEnhanced(
                          imageUrl: _avatarUrl!,
                        )
                      : Image.file(File(_avatarUrl!)),
                ),
              ),
            if (_avatarId != null)
              RandomAvatar(id: _avatarId ?? 0, size: 80, usage: widget.usage),
            Material(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  HapticFeedbackHelper.mediumImpact();
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      _avatarUrl = result.files.first.path;
                      _avatarId = null;
                    });

                    widget.onSelected(Avatar(
                      type: _avatarUrl!.startsWith('http')
                          ? AvatarType.network
                          : AvatarType.localFile,
                      url: _avatarUrl,
                    ));
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 100,
                        width: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: customColors.chatInputPanelText,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '自定义',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: customColors.chatInputPanelText
                                    ?.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            padding: const EdgeInsets.only(
              top: 15,
              left: 8,
              right: 8,
              bottom: 10,
            ),
            children: [
              for (String url in widget.externalAvatarUrls)
                _buildAvatarButton(
                  customColors,
                  Avatar(
                    type: AvatarType.network,
                    url: url,
                  ),
                ),
              for (int id in widget.externalAvatarIds)
                _buildAvatarButton(
                  customColors,
                  Avatar(type: AvatarType.random, id: id),
                ),
              // ...List.generate(
              //   200 -
              //       widget.externalAvatarIds.length -
              //       widget.externalAvatarUrls.length,
              //   (index) {
              //     return _buildAvatarButton(
              //         customColors,
              //         Avatar(
              //           type: AvatarType.random,
              //           id: widget.randomSeed + index,
              //         ));
              //   },
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarButton(CustomColors customColors, Avatar avatar) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: (_avatarUrl != null && _avatarUrl == avatar.url) ||
                  (_avatarId != null && _avatarId == avatar.id)
              ? customColors.linkColor ?? Colors.green
              : Colors.transparent,
          width: 4,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _avatarUrl = avatar.url;
            _avatarId = avatar.id;
          });

          widget.onSelected(avatar);
        },
        child: avatar.type == AvatarType.random
            ? RandomAvatar(id: avatar.id ?? 0, size: 80, usage: widget.usage)
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImageEnhanced(
                  imageUrl: avatar.url!,
                  fit: BoxFit.fill,
                ),
              ),
      ),
    );
  }
}
