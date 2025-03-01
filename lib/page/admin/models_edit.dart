import 'dart:io';
import 'dart:ui';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:askaide/bloc/model_bloc.dart';
import 'package:askaide/helper/upload.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/avatar_selector.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/admin/channels.dart';
import 'package:askaide/repo/api/admin/models.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';

class AdminModelEditPage extends StatefulWidget {
  final SettingRepository setting;
  final String modelId;
  const AdminModelEditPage({
    super.key,
    required this.setting,
    required this.modelId,
  });

  @override
  State<AdminModelEditPage> createState() => _AdminModelEditPageState();
}

class _AdminModelEditPageState extends State<AdminModelEditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController modelIdController = TextEditingController();
  final TextEditingController shortNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxContextController = TextEditingController();
  final TextEditingController inputPriceController = TextEditingController();
  final TextEditingController outputPriceController = TextEditingController();
  final TextEditingController perRequestPriceController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController searchPriceController = TextEditingController();
  final TextEditingController testUserIdsController = TextEditingController();
  final TextEditingController maxTokenPerMessageController = TextEditingController();

  /// 用于控制是否显示高级选项
  bool showAdvancedOptions = false;

  /// 视觉能力
  bool supportVision = false;

  /// 受限模型
  bool restricted = false;

  /// 模型状态
  bool modelEnabled = true;

  /// 是否是上新
  bool isNew = false;

  /// 是否是推荐模型
  bool isRecommended = false;

  /// 是否启用搜索
  bool enableSearch = false;

  /// 是否启用推理
  bool enableReasoning = false;

  /// 温度
  double temperature = 0.0;
  // 搜索结果数量
  int searchCount = 3;

  /// Tag
  final TextEditingController tagController = TextEditingController();
  String? tagTextColor;
  String? tagBgColor;

  /// 模型头像
  String? avatarUrl;
  List<String> avatarPresets = [];

  // 模型渠道
  List<AdminChannel> modelChannels = [];
  // 选择的渠道
  List<AdminModelProvider> providers = [];

  /// 是否锁定编辑
  bool editLocked = true;

  @override
  void dispose() {
    nameController.dispose();
    modelIdController.dispose();
    shortNameController.dispose();
    descriptionController.dispose();
    maxContextController.dispose();
    inputPriceController.dispose();
    outputPriceController.dispose();
    perRequestPriceController.dispose();
    promptController.dispose();
    categoryController.dispose();
    tagController.dispose();
    searchPriceController.dispose();
    testUserIdsController.dispose();
    maxTokenPerMessageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // 加载预设头像
    APIServer().avatars().then((value) {
      avatarPresets = value;
    });
    // 加载模型渠道
    APIServer().adminChannelsAgg().then((value) {
      setState(() {
        modelChannels = value;
      });

      // 加载模型
      context.read<ModelBloc>().add(ModelLoadEvent(widget.modelId));
    });

    // 初始值设置
    maxContextController.value = const TextEditingValue(text: '7500');
    inputPriceController.value = const TextEditingValue(text: '0');
    outputPriceController.value = const TextEditingValue(text: '0');
    perRequestPriceController.value = const TextEditingValue(text: '0');
    searchPriceController.value = const TextEditingValue(text: '0');
    testUserIdsController.value = const TextEditingValue(text: '');
    maxTokenPerMessageController.value = const TextEditingValue(text: '5000');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Edit Model',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: SingleChildScrollView(
            child: BlocListener<ModelBloc, ModelState>(
              listenWhen: (previous, current) => current is ModelOperationResult || current is ModelLoaded,
              listener: (context, state) {
                if (state is ModelOperationResult) {
                  if (state.success) {
                    showSuccessMessage(state.message);
                    context.read<ModelBloc>().add(ModelLoadEvent(widget.modelId));
                  } else {
                    showErrorMessage(state.message);
                  }
                }

                if (state is ModelLoaded) {
                  modelIdController.value = TextEditingValue(text: state.model.modelId);
                  nameController.value = TextEditingValue(text: state.model.name);
                  if (state.model.description != null) {
                    descriptionController.value = TextEditingValue(text: state.model.description!);
                  }

                  if (state.model.avatarUrl != null) {
                    avatarUrl = state.model.avatarUrl;
                  }

                  modelEnabled = state.model.status == 1;

                  if (state.model.providers.isNotEmpty) {
                    providers = state.model.providers;
                  }

                  if (state.model.meta != null) {
                    if (state.model.meta!.maxContext != null) {
                      maxContextController.value = TextEditingValue(text: state.model.meta!.maxContext.toString());
                    }

                    if (state.model.meta!.inputPrice != null) {
                      inputPriceController.value = TextEditingValue(text: state.model.meta!.inputPrice.toString());
                    }

                    if (state.model.meta!.outputPrice != null) {
                      outputPriceController.value = TextEditingValue(text: state.model.meta!.outputPrice.toString());
                    }

                    if (state.model.meta!.perReqPrice != null) {
                      perRequestPriceController.value =
                          TextEditingValue(text: state.model.meta!.perReqPrice.toString());
                    }

                    if (state.model.meta!.searchPrice != null) {
                      searchPriceController.value = TextEditingValue(text: state.model.meta!.searchPrice.toString());
                    }

                    shortNameController.value = TextEditingValue(text: state.model.shortName ?? '');
                    promptController.value = TextEditingValue(text: state.model.meta!.prompt ?? '');
                    supportVision = state.model.meta!.vision ?? false;
                    restricted = state.model.meta!.restricted ?? false;
                    tagController.value = TextEditingValue(text: state.model.meta!.tag ?? '');
                    tagTextColor = state.model.meta!.tagTextColor;
                    tagBgColor = state.model.meta!.tagBgColor;
                    isNew = state.model.meta!.isNew ?? false;
                    isRecommended = state.model.meta!.isRecommend ?? false;
                    categoryController.value = TextEditingValue(text: state.model.meta!.category ?? '');
                    enableSearch = state.model.meta!.search ?? false;
                    enableReasoning = state.model.meta!.reasoning ?? false;
                    temperature = state.model.meta!.temperature ?? 0.0;
                    searchCount = state.model.meta!.searchCount ?? 3;
                    searchCount = searchCount <= 3 ? 3 : searchCount;

                    if (state.model.meta!.testUserIds != null) {
                      testUserIdsController.value = TextEditingValue(text: state.model.meta!.testUserIds!.join(','));
                    }

                    if (state.model.meta!.maxTokenPerMessage != null && state.model.meta!.maxTokenPerMessage! > 0) {
                      maxTokenPerMessageController.value =
                          TextEditingValue(text: state.model.meta!.maxTokenPerMessage.toString());
                    }

                    setState(() {});
                  }
                }

                setState(() {
                  editLocked = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
                child: Column(
                  children: [
                    ColumnBlock(
                      children: [
                        EnhancedTextField(
                          labelText: 'ID',
                          customColors: customColors,
                          controller: modelIdController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Enter a unique ID',
                          maxLength: 100,
                          showCounter: false,
                          readOnly: true,
                        ),
                        EnhancedTextField(
                          labelText: 'Vendor',
                          customColors: customColors,
                          controller: categoryController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Enter a vendor name (Optional)',
                          maxLength: 100,
                          showCounter: false,
                        ),
                        EnhancedTextField(
                          labelText: 'Name',
                          customColors: customColors,
                          controller: nameController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Enter a model name',
                          maxLength: 100,
                          showCounter: false,
                        ),
                        EnhancedInput(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          title: Text(
                            'Avatar',
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
                                  image: avatarUrl == null
                                      ? null
                                      : DecorationImage(
                                          image: (avatarUrl!.startsWith('http')
                                              ? CachedNetworkImageProviderEnhanced(avatarUrl!)
                                              : FileImage(File(avatarUrl!))) as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: avatarUrl == null
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
                                      avatarUrl = selected.url;
                                    });
                                    context.pop();
                                  },
                                  usage: AvatarUsage.user,
                                  defaultAvatarUrl: avatarUrl,
                                  externalAvatarUrls: [
                                    ...avatarPresets,
                                  ],
                                );
                              },
                              heightFactor: 0.8,
                            );
                          },
                        ),
                        EnhancedTextField(
                          labelText: 'Description',
                          customColors: customColors,
                          controller: descriptionController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Optional',
                          maxLength: 255,
                          showCounter: false,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    ColumnBlock(
                      children: [
                        EnhancedTextField(
                          labelWidth: 120,
                          labelText: 'Input Price',
                          customColors: customColors,
                          controller: inputPriceController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Optional',
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textDirection: TextDirection.rtl,
                          suffixIcon: Container(
                            width: 110,
                            alignment: Alignment.center,
                            child: Text(
                              'Credits/1K Token',
                              style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                            ),
                          ),
                        ),
                        EnhancedTextField(
                          labelWidth: 120,
                          labelText: 'Output Price',
                          customColors: customColors,
                          controller: outputPriceController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Optional',
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textDirection: TextDirection.rtl,
                          suffixIcon: Container(
                            width: 110,
                            alignment: Alignment.center,
                            child: Text(
                              'Credits/1K Token',
                              style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                            ),
                          ),
                        ),
                        EnhancedTextField(
                          labelWidth: 120,
                          labelText: 'Request Price',
                          customColors: customColors,
                          controller: perRequestPriceController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Optional',
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textDirection: TextDirection.rtl,
                          suffixIcon: Container(
                            width: 110,
                            alignment: Alignment.center,
                            child: Text(
                              'Credits/Request',
                              style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                            ),
                          ),
                        ),
                        EnhancedTextField(
                          labelWidth: 120,
                          labelText: 'Search Price',
                          customColors: customColors,
                          controller: searchPriceController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Optional',
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textDirection: TextDirection.rtl,
                          suffixIcon: Container(
                            width: 110,
                            alignment: Alignment.center,
                            child: Text(
                              'Credits/Request',
                              style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                            ),
                          ),
                        ),
                        EnhancedTextField(
                          labelWidth: 150,
                          labelFontSize: 12,
                          labelText: 'Max Context Tokens',
                          customColors: customColors,
                          controller: maxContextController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Subtract the expected output length from the maximum context.',
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textDirection: TextDirection.rtl,
                          suffixIcon: Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              'Token',
                              style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                            ),
                          ),
                        ),
                        EnhancedTextField(
                          labelWidth: 150,
                          labelFontSize: 12,
                          labelText: 'Max Token Per Message',
                          customColors: customColors,
                          controller: maxTokenPerMessageController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: 'Optional',
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textDirection: TextDirection.rtl,
                          suffixIcon: Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              'Token',
                              style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ColumnBlock(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Vision',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    showBeautyDialog(
                                      context,
                                      type: QuickAlertType.info,
                                      text: 'Whether the current model supports visual capabilities.',
                                      confirmBtnText: AppLocale.gotIt.getString(context),
                                      showCancelBtn: false,
                                    );
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 16,
                                    color: customColors.weakLinkColor?.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              activeColor: customColors.linkColor,
                              value: supportVision,
                              onChanged: (value) {
                                setState(() {
                                  supportVision = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Deep Think',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    showBeautyDialog(
                                      context,
                                      type: QuickAlertType.info,
                                      text: 'Whether to enable Deep Think for the current model.',
                                      confirmBtnText: AppLocale.gotIt.getString(context),
                                      showCancelBtn: false,
                                    );
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 16,
                                    color: customColors.weakLinkColor?.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              activeColor: customColors.linkColor,
                              value: enableReasoning,
                              onChanged: (value) {
                                setState(() {
                                  enableReasoning = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Search',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    showBeautyDialog(
                                      context,
                                      type: QuickAlertType.info,
                                      text: 'Whether to enable search for the current model.',
                                      confirmBtnText: AppLocale.gotIt.getString(context),
                                      showCancelBtn: false,
                                    );
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 16,
                                    color: customColors.weakLinkColor?.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              activeColor: customColors.linkColor,
                              value: enableSearch,
                              onChanged: (value) {
                                setState(() {
                                  enableSearch = value;
                                });
                              },
                            ),
                          ],
                        ),
                        if (enableSearch)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Search Result Count', style: TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: searchCount.toDouble() <= 3 ? 3.0 : searchCount.toDouble(),
                                      min: 3,
                                      max: 50,
                                      divisions: 50 - 3,
                                      label: '$searchCount',
                                      activeColor: customColors.linkColor,
                                      onChanged: (value) {
                                        setState(() {
                                          searchCount = value.toInt();
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    '$searchCount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customColors.weakTextColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                      ],
                    ),
                    ImplicitlyAnimatedReorderableList<AdminModelProvider>(
                      items: providers,
                      shrinkWrap: true,
                      itemBuilder: (context, itemAnimation, item, index) {
                        return Reorderable(
                          key: ValueKey(item),
                          builder: (context, dragAnimation, inDrag) {
                            final t = dragAnimation.value;
                            final elevation = lerpDouble(0, 8, t);
                            final color = Color.lerp(Colors.white, Colors.white.withOpacity(0.8), t);

                            return SizeFadeTransition(
                              sizeFraction: 0.7,
                              curve: Curves.easeInOut,
                              animation: itemAnimation,
                              child: Material(
                                color: color,
                                elevation: elevation ?? 0,
                                type: MaterialType.transparency,
                                child: Slidable(
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      const SizedBox(width: 10),
                                      SlidableAction(
                                        label: AppLocale.delete.getString(context),
                                        borderRadius: CustomSize.borderRadiusAll,
                                        backgroundColor: Colors.red,
                                        icon: Icons.delete,
                                        onPressed: (_) {
                                          if (providers.length == 1) {
                                            showErrorMessage('At least one channel is needed');
                                            return;
                                          }

                                          openConfirmDialog(
                                            context,
                                            AppLocale.confirmToDeleteRoom.getString(context),
                                            () {
                                              setState(() {
                                                providers.removeAt(index);
                                              });
                                            },
                                            danger: true,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(5),
                                    title: ColumnBlock(
                                      margin: const EdgeInsets.all(0),
                                      children: [
                                        EnhancedInput(
                                          title: Text(
                                            'Channel',
                                            style: TextStyle(
                                              color: customColors.textfieldLabelColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          value: AutoSizeText(
                                            buildChannelName(item),
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: customColors.textfieldValueColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          onPressed: () {
                                            openListSelectDialog(
                                              context,
                                              <SelectorItem<AdminChannel>>[
                                                ...modelChannels
                                                    .map(
                                                      (e) => SelectorItem(
                                                        Text(
                                                          '${e.id == null ? '【Legacy】' : ''}${e.name}',
                                                          style: e.id == null
                                                              ? TextStyle(
                                                                  color: customColors.weakTextColorLess,
                                                                  decoration: TextDecoration.lineThrough,
                                                                )
                                                              : null,
                                                        ),
                                                        e,
                                                      ),
                                                    )
                                                    .toList(),
                                              ],
                                              (value) {
                                                setState(() {
                                                  providers[index].id = value.value.id;
                                                  if (value.value.id == null) {
                                                    providers[index].name = value.value.type;
                                                  }
                                                });
                                                return true;
                                              },
                                              heightFactor: 0.5,
                                              value: item,
                                            );
                                          },
                                        ),
                                        EnhancedTextField(
                                          labelWidth: 90,
                                          labelText: 'Rewrite',
                                          customColors: customColors,
                                          textAlignVertical: TextAlignVertical.top,
                                          hintText: 'Optional',
                                          maxLength: 100,
                                          showCounter: false,
                                          initValue: item.modelRewrite,
                                          onChanged: (value) {
                                            setState(() {
                                              providers[index].modelRewrite = value;
                                            });
                                          },
                                          labelHelpWidget: InkWell(
                                            onTap: () {
                                              showBeautyDialog(
                                                context,
                                                type: QuickAlertType.info,
                                                text:
                                                    'When the model identifier corresponding to the channel does not match the ID here, calling the channel interface will automatically replace the model with the value configured here.',
                                                confirmBtnText: AppLocale.gotIt.getString(context),
                                                showCancelBtn: false,
                                              );
                                            },
                                            child: Icon(
                                              Icons.help_outline,
                                              size: 16,
                                              color: customColors.weakLinkColor?.withAlpha(150),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  'Deep Think Model',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                const SizedBox(width: 5),
                                                InkWell(
                                                  onTap: () {
                                                    showBeautyDialog(
                                                      context,
                                                      type: QuickAlertType.info,
                                                      text: 'Whether the model is an Deep Thinking model.',
                                                      confirmBtnText: AppLocale.gotIt.getString(context),
                                                      showCancelBtn: false,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.help_outline,
                                                    size: 16,
                                                    color: customColors.weakLinkColor?.withAlpha(150),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            CupertinoSwitch(
                                              activeColor: customColors.linkColor,
                                              value: providers[index].type == 'reasoning',
                                              onChanged: (value) {
                                                setState(() {
                                                  providers[index].type = value ? 'reasoning' : 'default';
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Handle(
                                      delay: const Duration(milliseconds: 100),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue.withOpacity(0.1),
                                              border: Border.all(
                                                color: Colors.blue.withOpacity(0.3),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.1),
                                                  blurRadius: 2,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Icon(
                                            Icons.drag_indicator,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      areItemsTheSame: (AdminModelProvider oldItem, AdminModelProvider newItem) {
                        return oldItem.id == newItem.id;
                      },
                      onReorderFinished:
                          (AdminModelProvider item, int from, int to, List<AdminModelProvider> newItems) {
                        setState(() {
                          providers = newItems;
                        });
                      },
                    ),

                    const SizedBox(width: 10),
                    WeakTextButton(
                      title: 'Add Channel',
                      icon: Icons.add,
                      onPressed: () {
                        setState(() {
                          providers.add(AdminModelProvider());
                        });
                      },
                    ),
                    // 高级选项
                    if (showAdvancedOptions)
                      ColumnBlock(
                        innerPanding: 5,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Enabled',
                                style: TextStyle(fontSize: 16),
                              ),
                              CupertinoSwitch(
                                activeColor: customColors.linkColor,
                                value: modelEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    modelEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Temperature', style: TextStyle(fontSize: 16)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: temperature,
                                      min: 0.0,
                                      max: 2.0,
                                      divisions: 40,
                                      label: '$temperature',
                                      activeColor: customColors.linkColor,
                                      onChanged: (value) {
                                        setState(() {
                                          temperature = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    '$temperature',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customColors.weakTextColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          EnhancedTextField(
                            labelText: 'Abbr.',
                            customColors: customColors,
                            controller: shortNameController,
                            textAlignVertical: TextAlignVertical.top,
                            hintText: 'Enter model shorthand',
                            maxLength: 100,
                            showCounter: false,
                          ),
                          EnhancedTextField(
                            labelText: 'Tag',
                            customColors: customColors,
                            controller: tagController,
                            textAlignVertical: TextAlignVertical.top,
                            hintText: 'Enter tags',
                            maxLength: 100,
                            showCounter: false,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'New',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () {
                                      showBeautyDialog(
                                        context,
                                        type: QuickAlertType.info,
                                        text:
                                            'Whether to display a "New" icon next to the model to inform users that this is a new model.',
                                        confirmBtnText: AppLocale.gotIt.getString(context),
                                        showCancelBtn: false,
                                      );
                                    },
                                    child: Icon(
                                      Icons.help_outline,
                                      size: 16,
                                      color: customColors.weakLinkColor?.withAlpha(150),
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                activeColor: customColors.linkColor,
                                value: isNew,
                                onChanged: (value) {
                                  setState(() {
                                    isNew = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Recommended',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () {
                                      showBeautyDialog(
                                        context,
                                        type: QuickAlertType.info,
                                        text:
                                            'Whether to display a "Recommended" icon next to the model to inform users that this is a recommended model.',
                                        confirmBtnText: AppLocale.gotIt.getString(context),
                                        showCancelBtn: false,
                                      );
                                    },
                                    child: Icon(
                                      Icons.help_outline,
                                      size: 16,
                                      color: customColors.weakLinkColor?.withAlpha(150),
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                activeColor: customColors.linkColor,
                                value: isRecommended,
                                onChanged: (value) {
                                  setState(() {
                                    isRecommended = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Restricted',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () {
                                      showBeautyDialog(
                                        context,
                                        type: QuickAlertType.info,
                                        text:
                                            'Restricted models refer to models that cannot be used in Chinese Mainland due to policy factors.',
                                        confirmBtnText: AppLocale.gotIt.getString(context),
                                        showCancelBtn: false,
                                      );
                                    },
                                    child: Icon(
                                      Icons.help_outline,
                                      size: 16,
                                      color: customColors.weakLinkColor?.withAlpha(150),
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                activeColor: customColors.linkColor,
                                value: restricted,
                                onChanged: (value) {
                                  setState(() {
                                    restricted = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          EnhancedTextField(
                            labelPosition: LabelPosition.top,
                            labelText: 'System prompt',
                            customColors: customColors,
                            controller: promptController,
                            textAlignVertical: TextAlignVertical.top,
                            hintText: 'Global system prompt',
                            maxLength: 2000,
                            maxLines: 3,
                          ),
                          EnhancedTextField(
                            labelPosition: LabelPosition.top,
                            labelText: 'Test User IDs',
                            customColors: customColors,
                            controller: testUserIdsController,
                            textAlignVertical: TextAlignVertical.top,
                            hintText:
                                'Enter test user IDs, separated by commas.\nIf users are set here, the model is only visible to those users.',
                            maxLines: 3,
                            minLines: 2,
                            showCounter: false,
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        EnhancedButton(
                          title: showAdvancedOptions
                              ? AppLocale.simpleMode.getString(context)
                              : AppLocale.professionalMode.getString(context),
                          width: 120,
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
                          flex: 1,
                          child: EnhancedButton(
                            title: AppLocale.save.getString(context),
                            onPressed: onSubmit,
                            icon: editLocked
                                ? const Icon(Icons.lock, color: Colors.white, size: 16)
                                : const Icon(Icons.lock_open, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 提交
  void onSubmit() async {
    if (editLocked) {
      return;
    }

    if (nameController.text.isEmpty) {
      showErrorMessage('Please enter a model name');
      return;
    }

    final ps = providers.where((e) => e.id != null || e.name != null).toList();
    if (ps.isEmpty) {
      showErrorMessage('At least one channel is required');
      return;
    }

    if (testUserIdsController.text.isNotEmpty) {
      try {
        testUserIdsController.text.split(',').where((e) => e.trim() != '').map((e) => int.parse(e.trim())).toList();
      } catch (e) {
        showErrorMessage('Test user IDs must be comma-separated integers');
        return;
      }
    }

    if (avatarUrl != null && (!avatarUrl!.startsWith('http://') && !avatarUrl!.startsWith('https://'))) {
      final cancel = BotToast.showCustomLoading(
        toastBuilder: (cancel) {
          return const LoadingIndicator(
            message: 'Uploading avatar, please wait...',
          );
        },
        allowClick: false,
      );

      try {
        final res = await ImageUploader(widget.setting).upload(avatarUrl!, usage: 'avatar');
        avatarUrl = res.url;
      } catch (e) {
        showErrorMessage('Failed to upload avatar');
        cancel();
        return;
      } finally {
        cancel();
      }
    }

    final model = AdminModelUpdateReq(
      name: nameController.text,
      description: descriptionController.text,
      shortName: shortNameController.text,
      meta: AdminModelMeta(
        maxContext: int.parse(maxContextController.text),
        inputPrice: int.parse(inputPriceController.text),
        outputPrice: int.parse(outputPriceController.text),
        perReqPrice: int.parse(perRequestPriceController.text),
        prompt: promptController.text,
        vision: supportVision,
        restricted: restricted,
        category: categoryController.text,
        tag: tagController.text,
        tagTextColor: tagTextColor,
        tagBgColor: tagBgColor,
        isNew: isNew,
        isRecommend: isRecommended,
        search: enableSearch,
        reasoning: enableReasoning,
        temperature: temperature,
        searchCount: searchCount,
        searchPrice: int.parse(searchPriceController.text),
        testUserIds:
            testUserIdsController.text.split(',').where((e) => e.trim() != '').map((e) => int.parse(e.trim())).toList(),
        maxTokenPerMessage: int.parse(maxTokenPerMessageController.text),
      ),
      status: modelEnabled ? 1 : 2,
      providers: ps,
      avatarUrl: avatarUrl,
    );

    setState(() {
      editLocked = true;
    });

    // ignore: use_build_context_synchronously
    context.read<ModelBloc>().add(ModelUpdateEvent(widget.modelId, model));
  }

  /// 渠道名称
  String buildChannelName(AdminModelProvider provider) {
    if (provider.id != null) {
      return modelChannels.firstWhere((e) => e.id == provider.id).name;
    }

    if (provider.name != null) {
      return modelChannels
          .firstWhere(
            (e) => e.type == provider.name! && e.id == null,
            orElse: () => AdminChannel(name: 'Unknown', type: ''),
          )
          .display;
    }

    return 'Select';
  }
}
