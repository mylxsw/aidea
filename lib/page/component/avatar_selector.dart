import 'dart:io';

import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

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

  final int? defaultAvatarId;
  final String? defaultAvatarUrl;

  final List<int> externalAvatarIds;
  final List<String> externalAvatarUrls;

  final AvatarUsage usage;

  const AvatarSelector({
    super.key,
    required this.onSelected,
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
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            padding: const EdgeInsets.only(
              top: 15,
              left: 8,
              right: 8,
              bottom: 10,
            ),
            children: [
              buildAvatarSelectBox(customColors, context),
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

  Widget buildAvatarSelectBox(CustomColors customColors, BuildContext context) {
    return Material(
      borderRadius: CustomSize.borderRadius,
      child: InkWell(
        borderRadius: CustomSize.borderRadiusAll,
        onTap: () async {
          HapticFeedbackHelper.mediumImpact();
          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
          if (result != null && result.files.isNotEmpty) {
            setState(() {
              _avatarUrl = result.files.first.path;
              _avatarId = null;
            });

            widget.onSelected(Avatar(
              type: _avatarUrl!.startsWith('http') ? AvatarType.network : AvatarType.localFile,
              url: _avatarUrl,
            ));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: CustomSize.borderRadius,
          ),
          child: _avatarId == null && _avatarUrl == null
              ? ClipRRect(
                  borderRadius: CustomSize.borderRadius,
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: customColors.chatInputPanelText,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocale.custom.getString(context),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: customColors.chatInputPanelText?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: CustomSize.borderRadius,
                        child: _avatarUrl!.startsWith('http')
                            ? CachedNetworkImageEnhanced(
                                imageUrl: _avatarUrl!,
                              )
                            : Image.file(File(_avatarUrl!)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.only(bottomLeft: CustomSize.radius, bottomRight: CustomSize.radius),
                        child: Container(
                          color: const Color.fromARGB(82, 0, 0, 0),
                          height: 25,
                          alignment: Alignment.center,
                          child: Text(
                            AppLocale.custom.getString(context),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAvatarButton(CustomColors customColors, Avatar avatar) {
    return InkWell(
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
              borderRadius: CustomSize.borderRadius,
              child: CachedNetworkImageEnhanced(
                imageUrl: avatar.url!,
                fit: BoxFit.fill,
              ),
            ),
    );
  }
}
