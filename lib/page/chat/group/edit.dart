import 'package:askaide/bloc/group_chat_bloc.dart';
import 'package:askaide/repo/model/group.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/avatar_selector.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/multi_item_selector.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class ModelWithMemberId {
  final Model model;
  final int? memberId;

  ModelWithMemberId(this.model, this.memberId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelWithMemberId &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          memberId == other.memberId;
}

class GroupEditPage extends StatefulWidget {
  final SettingRepository setting;
  final int groupId;

  const GroupEditPage({
    super.key,
    required this.groupId,
    required this.setting,
  });

  @override
  State<GroupEditPage> createState() => _GroupEditPageState();
}

class _GroupEditPageState extends State<GroupEditPage> {
  final _nameController = TextEditingController(text: '');

  String? _avatarUrl;
  List<String> avatarPresets = [];

  final randomSeed = Random().nextInt(10000);

  List<Model> models = [];
  List<ModelWithMemberId> selectedModels = [];

  Function? globalLoadingCancel;

  @override
  void initState() {
    super.initState();

    // 加载预定义头像
    APIServer().avatars().then((value) {
      avatarPresets = value;
    });

    // 加载模型
    APIServer().models().then((value) {
      setState(() {
        models = value;
      });
      context
          .read<GroupChatBloc>()
          .add(GroupChatLoadEvent(widget.groupId, forceUpdate: true));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.roomSetting.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: CustomSize.toolbarHeight,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: BlocListener<RoomBloc, RoomState>(
          listenWhen: (previous, current) =>
              current is GroupRoomUpdateResultState,
          listener: (context, state) {
            if (state is GroupRoomUpdateResultState) {
              globalLoadingCancel?.call();
              if (state.success) {
                showSuccessMessage(AppLocale.operateSuccess.getString(context));
              } else {
                showErrorMessageEnhanced(context,
                    state.error ?? AppLocale.operateFailed.getString(context));
              }

              context
                  .read<GroupChatBloc>()
                  .add(GroupChatLoadEvent(widget.groupId, forceUpdate: true));
            }
          },
          child: BlocConsumer<GroupChatBloc, GroupChatState>(
            listenWhen: (previous, current) => current is GroupChatLoaded,
            listener: (context, state) {
              if (state is GroupChatLoaded) {
                _nameController.text = state.group.group.name;
                _avatarUrl = state.group.group.avatarUrl;
                selectedModels = state.group.members
                    .where((e) => e.status != 2)
                    .map((e) {
                      final mod = models
                          .where((em) => e.modelId == em.realModelId)
                          .firstOrNull;
                      if (mod == null) {
                        return null;
                      }

                      return ModelWithMemberId(mod, e.id);
                    })
                    .where((e) => e != null)
                    .map((e) => e!)
                    .toList();

                final selectedModelIds =
                    selectedModels.map((e) => e.model.realModelId).toList();

                models = models
                    .where((e) =>
                        !e.disabled || selectedModelIds.contains(e.realModelId))
                    .toList();
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ColumnBlock(
                      children: [
                        // 名称
                        EnhancedTextField(
                          customColors: customColors,
                          controller: _nameController,
                          maxLength: 50,
                          maxLines: 1,
                          showCounter: false,
                          labelText: '名称',
                          labelPosition: LabelPosition.left,
                          hintText: AppLocale.required.getString(context),
                          textDirection: TextDirection.rtl,
                        ),
                        EnhancedInput(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          title: Text(
                            '头像',
                            style: TextStyle(
                              color: customColors.textfieldLabelColor,
                              fontSize: 16,
                            ),
                          ),
                          value: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: _avatarUrl == null
                                      ? null
                                      : DecorationImage(
                                          image: (_avatarUrl!.startsWith('http')
                                              ? CachedNetworkImageProviderEnhanced(
                                                  _avatarUrl!)
                                              : FileImage(File(
                                                  _avatarUrl!))) as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: _avatarUrl == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.interests,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                          onPressed: () {
                            openModalBottomSheet(
                              context,
                              (context) {
                                return AvatarSelector(
                                  onSelected: (selected) {
                                    setState(() {
                                      _avatarUrl = selected.url;
                                    });
                                    context.pop();
                                  },
                                  usage: AvatarUsage.room,
                                  randomSeed: randomSeed,
                                  defaultAvatarUrl: _avatarUrl,
                                  externalAvatarUrls: [
                                    ...avatarPresets,
                                  ],
                                );
                              },
                              heightFactor: 0.8,
                            );
                          },
                        ),
                      ],
                    ),
                    ColumnBlock(
                      children: [
                        // 成员
                        EnhancedInput(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          title: Text(
                            '成员',
                            style: TextStyle(
                              color: customColors.textfieldLabelColor,
                              fontSize: 16,
                            ),
                          ),
                          value: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: resolveSelectedModelsPreviewWidth(
                                        context),
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.hardEdge,
                                    child: buildSelectedModelsPreview(),
                                  ),
                                  if (selectedModels.isNotEmpty)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: customColors.tagsBackground,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'x${selectedModels.length}',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: customColors.weakTextColor,
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ],
                          ),
                          onPressed: () {
                            openModalBottomSheet(
                              context,
                              (context) {
                                return MultiItemSelector(
                                  itemBuilder: (item) {
                                    return Text(item.model.name);
                                  },
                                  items: models
                                      .map((e) => ModelWithMemberId(
                                          e,
                                          selectedModels
                                              .where(
                                                  (se) => se.model.id == e.id)
                                              .firstOrNull
                                              ?.memberId))
                                      .toList(),
                                  onChanged: (selected) {
                                    setState(() {
                                      selectedModels = selected;
                                    });
                                  },
                                  itemAvatarBuilder: (item) {
                                    return _buildAvatar(
                                      avatarUrl: item.model.avatarUrl,
                                      size: 30,
                                    );
                                  },
                                  selectedItems: selectedModels,
                                );
                              },
                              heightFactor: 0.8,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: EnhancedButton(
                            title: AppLocale.save.getString(context),
                            color:
                                canSubmit() ? null : customColors.weakTextColor,
                            backgroundColor: canSubmit()
                                ? null
                                : customColors.weakTextColor!.withAlpha(20),
                            onPressed: () async {
                              if (!canSubmit()) {
                                return;
                              }

                              globalLoadingCancel = BotToast.showCustomLoading(
                                toastBuilder: (cancel) {
                                  return LoadingIndicator(
                                    message: AppLocale.processingWait
                                        .getString(context),
                                  );
                                },
                                allowClick: false,
                                duration: const Duration(seconds: 120),
                              );

                              final name = _nameController.text.trim();
                              if (name == '') {
                                globalLoadingCancel?.call();
                                showErrorMessage('请输入群组名称');
                                return;
                              }

                              try {
                                if (_avatarUrl != null) {
                                  if (!(_avatarUrl!.startsWith('http://') ||
                                      _avatarUrl!.startsWith('https://'))) {
                                    // 上传文件，获取 URL
                                    final cancel = BotToast.showCustomLoading(
                                      toastBuilder: (cancel) {
                                        return const LoadingIndicator(
                                          message: "正在上传图片，请稍后...",
                                        );
                                      },
                                      allowClick: false,
                                    );

                                    final uploadRes =
                                        await ImageUploader(widget.setting)
                                            .upload(_avatarUrl!,
                                                usage: 'avatar')
                                            .whenComplete(() => cancel());
                                    _avatarUrl = uploadRes.url;
                                  }
                                }

                                if (context.mounted) {
                                  context.read<RoomBloc>().add(
                                        GroupRoomUpdateEvent(
                                          groupId: widget.groupId,
                                          name: name,
                                          avatarUrl: _avatarUrl,
                                          members: selectedModels
                                              .map((e) => GroupMember(
                                                  modelId: e.model.realModelId,
                                                  modelName: e.model.shortName,
                                                  id: e.memberId))
                                              .toList(),
                                        ),
                                      );
                                }
                              } catch (e) {
                                globalLoadingCancel?.call();
                                // ignore: use_build_context_synchronously
                                showErrorMessageEnhanced(context, e);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool canSubmit() {
    if (selectedModels.isEmpty) {
      return false;
    }

    if (_nameController.text.trim() == '') {
      return false;
    }

    return true;
  }

  Widget buildSelectedModelsPreview() {
    if (selectedModels.isEmpty) {
      return const Center(
        child: Icon(
          Icons.group,
          color: Colors.grey,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < selectedModels.length; i++)
          i == 0
              ? _buildAvatar(
                  avatarUrl: selectedModels.first.model.avatarUrl,
                  size: 30,
                )
              : Positioned(
                  left: i * 15.0,
                  child: _buildAvatar(
                    avatarUrl: selectedModels[i].model.avatarUrl,
                    size: 30,
                  ),
                ),
      ],
    );
  }

  Widget _buildAvatar({String? avatarUrl, int? id, int size = 30}) {
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(avatarUrl, qiniuImageTypeAvatar),
        size: size,
      );
    }

    return RandomAvatar(
      id: id ?? 0,
      size: size,
      usage:
          Ability().supportAPIServer() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }

  double resolveSelectedModelsPreviewWidth(BuildContext context) {
    final maxSize = MediaQuery.of(context).size.width - 180;
    final expectSize = 45.0 + selectedModels.length * 15;

    return expectSize > maxSize ? maxSize : expectSize;
  }
}
