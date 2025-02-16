import 'dart:io';
import 'dart:math';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/character_create.dart';
import 'package:askaide/page/component/advanced_button.dart';
import 'package:askaide/page/component/avatar_selector.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class CharacterEditPage extends StatefulWidget {
  final int roomId;
  final SettingRepository setting;
  const CharacterEditPage({super.key, required this.roomId, required this.setting});

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController(text: '');

  final randomSeed = Random().nextInt(10000);

  String? _originalAvatarUrl;
  int? _originalAvatarId;

  String? _avatarUrl;
  int? _avatarId;

  List<String> avatarPresets = [];

  int maxContext = 5;

  List<ChatMemory> validMemories = [
    ChatMemory('Ephemeral', 1, description: 'Each conversation is independent, often used for one-off Q&A'),
    ChatMemory('Basic', 3, description: 'Remembers the last 3 conversations'),
    ChatMemory('Medium', 6, description: 'Remembers the last 6 conversations'),
    ChatMemory('Deep', 10, description: 'Remembers the last 10 conversations')
  ];

  bool showAdvancedOptions = false;

  mm.Model? _selectedModel;
  String? reservedModel;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<RoomBloc>(context).add(RoomLoadEvent(widget.roomId, cascading: false));

    // 获取预设头像
    if (Ability().isUserLogon()) {
      APIServer().avatars().then((value) {
        avatarPresets = value;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocale.configure.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          elevation: 0,
          toolbarHeight: CustomSize.toolbarHeight,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: BlocConsumer<RoomBloc, RoomState>(
            listener: (context, state) {
              if (state is RoomLoaded) {
                _nameController.text = state.room.name;
                _promptController.text = state.room.systemPrompt ?? '';
                maxContext = state.room.maxContext;

                ModelAggregate.model(state.room.model).then((value) {
                  setState(() {
                    _selectedModel = value;
                    reservedModel = value.id;
                  });
                });

                if (state.room.avatarUrl != null && state.room.avatarUrl != '') {
                  setState(() {
                    _avatarUrl = state.room.avatarUrl;
                    _avatarId = null;

                    _originalAvatarUrl = state.room.avatarUrl;
                    _originalAvatarId = null;
                  });
                } else if (state.room.avatarId != null && state.room.avatarId != 0) {
                  setState(() {
                    _avatarId = state.room.avatarId;
                    _avatarUrl = null;

                    _originalAvatarId = state.room.avatarId;
                    _originalAvatarUrl = null;
                  });
                } else {
                  setState(() {
                    _avatarId = null;
                    _avatarUrl = null;

                    _originalAvatarId = state.room.id;
                    _originalAvatarUrl = null;
                  });
                }
              }

              if (state is RoomOperationResult) {
                if (state.success) {
                  if (state.redirect != null) {
                    context.push(state.redirect!).then((value) {
                      context.read<RoomBloc>().add(RoomsLoadEvent());
                    });
                  }
                } else {
                  showErrorMessageEnhanced(context, state.error ?? AppLocale.operateFailed.getString(context));
                }
              }
            },
            buildWhen: (previous, current) => current is RoomLoaded,
            builder: (context, state) {
              if (state is RoomLoaded) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // 名称
                        if (state.room.category != 'system')
                          ColumnBlock(
                            children: [
                              EnhancedTextField(
                                customColors: customColors,
                                controller: _nameController,
                                maxLength: 50,
                                maxLines: 1,
                                showCounter: false,
                                labelText: AppLocale.roomName.getString(context),
                                labelPosition: LabelPosition.left,
                                hintText: AppLocale.required.getString(context),
                                textDirection: TextDirection.rtl,
                              ),
                              if (Ability().isUserLogon())
                                EnhancedInput(
                                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                                  title: Text(
                                    AppLocale.avatar.getString(context),
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
                                          borderRadius: CustomSize.borderRadius,
                                          image: _avatarUrl == null
                                              ? null
                                              : DecorationImage(
                                                  image: (_avatarUrl!.startsWith('http')
                                                      ? CachedNetworkImageProviderEnhanced(_avatarUrl!)
                                                      : FileImage(File(_avatarUrl!))) as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        child: _avatarUrl == null && _avatarId == null
                                            ? const Center(
                                                child: Icon(
                                                  Icons.interests,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : (_avatarId == null
                                                ? const SizedBox()
                                                : RandomAvatar(
                                                    id: _avatarId!,
                                                    usage: AvatarUsage.room,
                                                  )),
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
                                              _avatarId = selected.id;
                                            });
                                            context.pop();
                                          },
                                          usage: AvatarUsage.room,
                                          defaultAvatarId: _avatarId,
                                          defaultAvatarUrl: _avatarUrl,
                                          externalAvatarIds: _originalAvatarId == null ? [] : [_originalAvatarId!],
                                          externalAvatarUrls: _originalAvatarUrl == null
                                              ? [...avatarPresets]
                                              : [_originalAvatarUrl!, ...avatarPresets],
                                        );
                                      },
                                      heightFactor: 0.8,
                                    );
                                  },
                                ),
                            ],
                          ),

                        ColumnBlock(
                          innerPanding: 10,
                          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                          children: [
                            // 提示语
                            EnhancedTextField(
                              fontSize: 12,
                              customColors: customColors,
                              controller: _promptController,
                              labelText: AppLocale.prompt.getString(context),
                              labelPosition: LabelPosition.top,
                              hintText: AppLocale.promptHint.getString(context),
                              bottomButton: Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    size: 13,
                                    color: customColors.linkColor?.withAlpha(150),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppLocale.examples.getString(context),
                                    style: TextStyle(
                                      color: customColors.linkColor?.withAlpha(150),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              bottomButtonOnPressed: () async {
                                openSystemPromptSelectDialog(
                                  context,
                                  customColors,
                                  _promptController,
                                );
                              },
                              minLines: 4,
                              maxLines: 20,
                              showCounter: false,
                            ),
                          ],
                        ),
                        if (showAdvancedOptions)
                          ColumnBlock(
                            innerPanding: 10,
                            padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 0),
                            children: [
                              // 模型
                              EnhancedInputSimple(
                                title: AppLocale.model.getString(context),
                                padding: const EdgeInsets.only(top: 10, bottom: 0),
                                onPressed: () {
                                  openSelectModelDialog(
                                    context,
                                    (selected) {
                                      setState(() {
                                        _selectedModel = selected;
                                      });
                                    },
                                    initValue: _selectedModel?.uid(),
                                    reservedModels: reservedModel != null ? [reservedModel!] : [],
                                  );
                                },
                                value:
                                    _selectedModel != null ? _selectedModel!.name : AppLocale.select.getString(context),
                              ),
                              EnhancedInput(
                                title: Text(
                                  AppLocale.memoryDepth.getString(context),
                                  style: TextStyle(
                                    color: customColors.textfieldLabelColor,
                                    fontSize: 16,
                                  ),
                                ),
                                value: Text(
                                  validMemories.where((element) => element.number == maxContext).firstOrNull?.name ??
                                      '',
                                ),
                                onPressed: () {
                                  openListSelectDialog(
                                    context,
                                    validMemories
                                        .map(
                                          (e) => SelectorItem(
                                            Column(
                                              children: [
                                                Text(
                                                  e.name,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  e.description ?? '',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: customColors.weakTextColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            e.number,
                                          ),
                                        )
                                        .toList(),
                                    (value) {
                                      setState(() {
                                        maxContext = value.value;
                                      });
                                      return true;
                                    },
                                    heightFactor: 0.5,
                                    value: validMemories.where((element) => element.number == maxContext).firstOrNull,
                                  );
                                },
                              ),
                            ],
                          ),
                        AdvancedButton(
                          showAdvancedOptions: showAdvancedOptions,
                          onPressed: (value) {
                            setState(() {
                              showAdvancedOptions = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        EnhancedButton(
                          title: AppLocale.save.getString(context),
                          onPressed: () async {
                            if (_nameController.text == '') {
                              showErrorMessage(AppLocale.nameRequiredMessage.getString(context));
                              return;
                            }

                            if (_promptController.text == '') {
                              showErrorMessage(AppLocale.charactorPromptRequiredMessage.getString(context));
                              return;
                            }

                            if (_avatarUrl != null) {
                              if (!(_avatarUrl!.startsWith('http://') || _avatarUrl!.startsWith('https://'))) {
                                // 上传文件，获取 URL
                                final cancel = BotToast.showCustomLoading(
                                  toastBuilder: (cancel) {
                                    return LoadingIndicator(
                                      message: AppLocale.imageUploading.getString(context),
                                    );
                                  },
                                  allowClick: false,
                                );

                                final uploadRes = await ImageUploader(widget.setting)
                                    .upload(_avatarUrl!, usage: 'avatar')
                                    .whenComplete(() => cancel());
                                _avatarUrl = uploadRes.url;
                              }
                            }

                            if (context.mounted) {
                              context.read<RoomBloc>().add(
                                    RoomUpdateEvent(
                                      widget.roomId,
                                      name: _nameController.text,
                                      model: _selectedModel?.uid(),
                                      prompt: _promptController.text,
                                      avatarUrl: _avatarUrl,
                                      avatarId: _avatarId,
                                      maxContext: maxContext,
                                    ),
                                  );

                              showSuccessMessage(AppLocale.operateSuccess.getString(context));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
