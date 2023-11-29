import 'dart:io';
import 'dart:math';

import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
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
import 'package:askaide/page/component/room_card.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/api/room_gallery.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/model.dart';
import 'package:askaide/page/component/model_item.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/model/model.dart' as mm;
import 'package:go_router/go_router.dart';

/// 创建聊天室对话框
class RoomCreatePage extends StatefulWidget {
  final SettingRepository setting;
  const RoomCreatePage({super.key, required this.setting});

  @override
  State<RoomCreatePage> createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends State<RoomCreatePage> {
  final _nameController = TextEditingController(text: '');
  final _promptController = TextEditingController(text: '');
  final _initMessageController = TextEditingController(text: '');

  final randomSeed = Random().nextInt(10000);

  String? _avatarUrl;
  int? _avatarId;

  List<String> avatarPresets = [];

  int maxContext = 3;

  List<ChatMemory> validMemories = [
    ChatMemory('无记忆', 1, description: '每次对话都是独立的，常用于一次性问答'),
    ChatMemory('基础', 3, description: '记住最近的 3 次对话'),
    ChatMemory('中等', 6, description: '记住最近的 6 次对话'),
    ChatMemory('深度', 10, description: '记住最近的 10 次对话'),
  ];

  bool showAdvancedOptions = false;

  mm.Model? _selectedModel;

  List<RoomGallery> selectedSuggestions = [];
  List<String> tags = [];

  @override
  void initState() {
    super.initState();

    if (Ability().enableAPIServer()) {
      APIServer().avatars().then((value) {
        avatarPresets = value;
      });

      context.read<RoomBloc>().add(RoomGalleriesLoadEvent());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _initMessageController.dispose();
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
        backgroundColor: customColors.backgroundContainerColor,
        centerTitle: true,
        toolbarHeight: CustomSize.toolbarHeight,
      ),
      body: BackgroundContainer(
        setting: widget.setting,
        maxWidth: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Ability().enableAPIServer()
              ? SafeArea(
                  top: false,
                  child: DefaultTabController(
                    length: tags.length + (selectedSuggestions.isEmpty ? 1 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context)
                                .colorScheme
                                .copyWith(surfaceVariant: Colors.transparent),
                          ),
                          child: TabBar(
                            tabs: [
                              for (var tag in tags) Tab(text: tag),
                              if (selectedSuggestions.isEmpty)
                                const Tab(text: '自定义'),
                            ],
                            isScrollable: true,
                            labelColor: customColors.linkColor,
                            indicator: const BoxDecoration(),
                            labelPadding:
                                const EdgeInsets.only(right: 5, left: 10),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            tabAlignment: TabAlignment.center,
                          ),
                        ),
                        Expanded(
                          child: BlocConsumer<RoomBloc, RoomState>(
                            listenWhen: (previous, current) =>
                                current is RoomGalleriesLoaded,
                            listener: (context, state) {
                              if (state is RoomGalleriesLoaded) {
                                if (state.error != null) {
                                  showErrorMessageEnhanced(
                                      context, state.error!);
                                }

                                if (state.galleries.isNotEmpty) {
                                  tags = state.tags;

                                  setState(() {});
                                }
                              }
                            },
                            buildWhen: (previous, current) =>
                                current is RoomGalleriesLoaded,
                            builder: (context, state) {
                              if (state is RoomGalleriesLoaded) {
                                return TabBarView(
                                  children: [
                                    for (var tag in tags)
                                      buildSuggestTab(
                                        customColors,
                                        context,
                                        state.galleries
                                            .where((element) =>
                                                element.tags.contains(tag))
                                            .toList(),
                                      ),
                                    if (selectedSuggestions.isEmpty)
                                      buildCustomTab(customColors, context),
                                  ],
                                );
                              }

                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : buildCustomTab(customColors, context),
        ),
      ),
      bottomNavigationBar: selectedSuggestions.isNotEmpty
          ? SafeArea(
              child: Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    WeakTextButton(
                      title: AppLocale.cancel.getString(context),
                      onPressed: () {
                        selectedSuggestions.clear();
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: EnhancedButton(
                        title: AppLocale.ok.getString(context),
                        onPressed: () {
                          context.read<RoomBloc>().add(GalleryRoomCopyEvent(
                              selectedSuggestions.map((e) => e.id).toList()));
                          showSuccessMessage(
                              AppLocale.operateSuccess.getString(context));
                          context.pop();
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget buildSuggestTab(
    CustomColors customColors,
    BuildContext context,
    List<RoomGallery> galleries,
  ) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: _calculateSuggestCrossAxisCount(),
      childAspectRatio: 0.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 2,
      padding: const EdgeInsets.all(10),
      children: galleries
          .map(
            (item) => RoomCard(
              item: item,
              onItemSelected: onItemSelected,
              selected: selectedSuggestions.contains(item),
              fontsize: 15,
              stopAllEvents: true,
            ),
          )
          .toList(),
    );
  }

  void onItemSelected(RoomGallery item) {
    if (selectedSuggestions.contains(item)) {
      selectedSuggestions.remove(item);
    } else {
      selectedSuggestions.add(item);
    }

    setState(() {});
  }

  Widget buildCustomTab(CustomColors customColors, BuildContext context) {
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
              if (Ability().enableAPIServer())
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
                                          : FileImage(File(_avatarUrl!)))
                                      as ImageProvider,
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
                          randomSeed: randomSeed,
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
            children: [
              if (_selectedModel != null && !_selectedModel!.isChatModel)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Text(
                    defaultModelNotChatDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 244, 155, 54)),
                  ),
                ),

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
                value: _selectedModel != null
                    ? _selectedModel!.name
                    : AppLocale.select.getString(context),
              ),
              // 提示语
              if (_selectedModel != null && _selectedModel!.isChatModel)
                EnhancedTextField(
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
                        '示例',
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
                  maxLines: 8,
                  showCounter: false,
                ),
            ],
          ),
          if (showAdvancedOptions)
            ColumnBlock(
              innerPanding: 10,
              padding: const EdgeInsets.only(
                  top: 15, left: 15, right: 15, bottom: 5),
              children: [
                EnhancedTextField(
                  customColors: customColors,
                  controller: _initMessageController,
                  labelText: '引导语',
                  labelPosition: LabelPosition.top,
                  hintText: '每次开始新对话时，系统将会以 AI 的身份自动发送引导语。',
                  maxLines: 3,
                  showCounter: false,
                  maxLength: 1000,
                ),
                EnhancedInput(
                  title: Text(
                    '记忆深度',
                    style: TextStyle(
                      color: customColors.textfieldLabelColor,
                      fontSize: 16,
                    ),
                  ),
                  value: Text(
                    validMemories
                            .where((element) => element.number == maxContext)
                            .firstOrNull
                            ?.name ??
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
                      value: validMemories
                          .where((element) => element.number == maxContext)
                          .firstOrNull,
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              EnhancedButton(
                title: showAdvancedOptions ? '收起选项' : '高级选项',
                width: 100,
                backgroundColor: Colors.transparent,
                color: customColors.weakLinkColor,
                fontSize: 15,
                icon: Icon(
                  showAdvancedOptions ? Icons.unfold_less : Icons.unfold_more,
                  color: customColors.weakLinkColor,
                  size: 15,
                ),
                onPressed: () {
                  setState(() {
                    showAdvancedOptions = !showAdvancedOptions;
                  });
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EnhancedButton(
                  title: AppLocale.ok.getString(context),
                  onPressed: () async {
                    if (_nameController.text == '') {
                      showErrorMessage(
                          AppLocale.nameRequiredMessage.getString(context));
                      return;
                    }

                    if (_promptController.text.length > 1000) {
                      showErrorMessage(
                          AppLocale.promptFormatError.getString(context));
                      return;
                    }

                    if (_selectedModel == null) {
                      showErrorMessage(
                          AppLocale.modelRequiredMessage.getString(context));
                      return;
                    }

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
                              _selectedModel!.uid(),
                              _promptController.text,
                              avatarId: _avatarId,
                              avatarUrl: _avatarUrl,
                              maxContext: maxContext,
                              initMessage: _initMessageController.text,
                            ),
                          );

                      context.pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateSuggestCrossAxisCount() {
    var width = MediaQuery.of(context).size.width;
    if (width > CustomSize.maxWindowSize) {
      width = CustomSize.maxWindowSize;
    }

    final crossAxisCount = (width / 160).floor();
    return crossAxisCount > 7 ? 7 : crossAxisCount;
  }
}

void openSelectModelDialog(
  BuildContext context,
  Function(mm.Model selected) onSelected, {
  String? initValue,
  List<String>? reservedModels,
}) {
  openModalBottomSheet(
    context,
    (context) {
      return FutureBuilder(
          future: ModelAggregate.models(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              showErrorMessage(resolveError(context, snapshot.error!));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ModelItem(
              models: snapshot.data!
                  .where((e) =>
                      !e.disabled ||
                      (reservedModels != null && reservedModels.contains(e.id)))
                  .toList(),
              onSelected: (selected) {
                onSelected(selected);
                context.pop();
              },
              initValue: initValue,
            );
          });
    },
    heightFactor: 0.7,
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
                          textScaleFactor: 0.8,
                        )
                      ],
                    ),
                    e.content,
                    search: (keywrod) =>
                        e.title.toLowerCase().contains(keywrod.toLowerCase()),
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
    heightFactor: 0.7,
  );
}

class ChatMemory {
  String name;
  String? description;
  int number;

  ChatMemory(this.name, this.number, {this.description});
}
