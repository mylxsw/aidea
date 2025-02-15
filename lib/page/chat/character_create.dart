import 'dart:io';
import 'dart:math';

import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
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
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/page/component/model_item.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:go_router/go_router.dart';

/// 创建聊天室对话框
class CharacterCreatePage extends StatefulWidget {
  final SettingRepository setting;
  const CharacterCreatePage({super.key, required this.setting});

  @override
  State<CharacterCreatePage> createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  final _nameController = TextEditingController(text: '');
  final _promptController = TextEditingController(text: '');

  final randomSeed = Random().nextInt(10000);

  String? _avatarUrl;
  int? _avatarId;

  List<String> avatarPresets = [];

  int maxContext = 6;

  List<ChatMemory> validMemories = [
    ChatMemory('Ephemeral', 1, description: 'Each conversation is independent, often used for one-off Q&A'),
    ChatMemory('Basic', 3, description: 'Remembers the last 3 conversations'),
    ChatMemory('Medium', 6, description: 'Remembers the last 6 conversations'),
    ChatMemory('Deep', 10, description: 'Remembers the last 10 conversations')
  ];

  bool showAdvancedOptions = false;

  mm.Model? _selectedModel;

  List<String> tags = [];

  @override
  void initState() {
    super.initState();

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.createRoom.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        backgroundColor: customColors.backgroundColor,
        centerTitle: true,
        toolbarHeight: CustomSize.toolbarHeight,
      ),
      backgroundColor: customColors.backgroundColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        maxWidth: CustomSize.maxWindowSize,
        backgroundColor: customColors.backgroundColor,
        child: BlocListener<RoomBloc, RoomState>(
          listenWhen: (previous, current) => current is RoomOperationResult,
          listener: (context, state) {
            if (state is RoomOperationResult) {
              if (state.success) {
                if (state.redirect != null) {
                  context.push(state.redirect!).then((value) {
                    if (context.mounted) {
                      context.read<RoomBloc>().add(RoomsLoadEvent());
                    }
                  });
                } else {
                  context.pop();
                }
              } else {
                showErrorMessageEnhanced(context, state.error ?? AppLocale.operateFailed.getString(context));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: buildCustomCharacter(customColors, context),
          ),
        ),
      ),
    );
  }

  Widget buildCustomCharacter(CustomColors customColors, BuildContext context) {
    return SingleChildScrollView(
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
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
              children: [
                // 模型
                EnhancedInputSimple(
                  title: AppLocale.model.getString(context),
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  onPressed: () {
                    openSelectModelDialog(
                      context,
                      (selected) {
                        setState(() {
                          _selectedModel = selected;
                        });
                      },
                      initValue: _selectedModel?.uid(),
                    );
                  },
                  value: _selectedModel != null ? _selectedModel!.name : AppLocale.select.getString(context),
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
                    validMemories.where((element) => element.number == maxContext).firstOrNull?.name ?? '',
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
            title: AppLocale.ok.getString(context),
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
                      RoomCreateEvent(
                        _nameController.text,
                        _promptController.text,
                        model: _selectedModel?.uid(),
                        avatarId: _avatarId,
                        avatarUrl: _avatarUrl,
                        maxContext: maxContext,
                      ),
                    );
              }
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

void openSelectModelDialog(
  BuildContext context,
  Function(mm.Model? selected) onSelected, {
  String? initValue,
  List<String>? reservedModels,
  String? title,
  String? priorityModelId,
  bool withCustom = false,
}) {
  future() async {
    final models = await ModelAggregate.models(cache: true);

    if (priorityModelId != null) {
      // 将 models 中，id 与 priorityModelId 相同的元素排序到最前面
      final index = models.indexWhere((e) => e.id == priorityModelId || e.uid() == priorityModelId);
      if (index != -1) {
        models.insert(
            0,
            models[index]
                // ignore: use_build_context_synchronously
                .copyWith(category: AppLocale.recentlyUsed.getString(context)));
      }
    }

    // 再请求一次，用于异步更新 Cache，下次打开时将显示最新数据
    ModelAggregate.models(cache: false);

    return models;
  }

  openModalBottomSheet(
    context,
    (context) {
      return FutureBuilder(
          future: future(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              showErrorMessage(resolveError(context, snapshot.error!));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ModelItem(
              models: snapshot.data!
                  .where((e) => !e.disabled || (reservedModels != null && reservedModels.contains(e.id)))
                  .toList(),
              onSelected: (selected) {
                onSelected(selected);
                context.pop();
              },
              initValue: initValue,
            );
          });
    },
    heightFactor: 0.9,
    title: title,
  );
}

void openSystemPromptSelectDialog(
  BuildContext context,
  CustomColors customColors,
  TextEditingController promptController,
) {
  openModalBottomSheet(
    context,
    (context) {
      return FutureBuilder(
        future: APIServer().prompts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            showErrorMessage(resolveError(context, snapshot.error!));
          }

          return ItemSearchSelector(
            items: (snapshot.data ?? [])
                .map(
                  (e) => SelectorItem<String>(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          e.title,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: customColors.chatExampleItemText,
                          ),
                        ),
                        Text(
                          e.content,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: customColors.weakTextColor,
                          ),
                          textScaler: const TextScaler.linear(0.8),
                        )
                      ],
                    ),
                    e.content,
                    search: (keywrod) => e.title.toLowerCase().contains(keywrod.toLowerCase()),
                  ),
                )
                .toList(),
            onSelected: (value) {
              promptController.text = value.value;
              return true;
            },
          );
        },
      );
    },
    heightFactor: 0.9,
  );
}

class ChatMemory {
  String name;
  String? description;
  int number;

  ChatMemory(this.name, this.number, {this.description});
}
