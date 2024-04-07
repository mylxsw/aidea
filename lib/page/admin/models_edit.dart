import 'dart:io';

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
import 'package:askaide/repo/api/admin/channels.dart';
import 'package:askaide/repo/api/admin/models.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
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
  final TextEditingController promptController = TextEditingController();

  /// 用于控制是否显示高级选项
  bool showAdvancedOptions = false;

  /// 视觉能力
  bool supportVision = false;

  /// 受限模型
  bool restricted = false;

  /// 模型状态
  bool modelEnabled = true;

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
    promptController.dispose();

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
    maxContextController.value = const TextEditingValue(text: '3500');
    inputPriceController.value = const TextEditingValue(text: '1');
    outputPriceController.value = const TextEditingValue(text: '1');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: const Text(
          '编辑模型',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
      ),
      backgroundColor: customColors.chatInputPanelBackground,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: SingleChildScrollView(
          child: BlocListener<ModelBloc, ModelState>(
            listenWhen: (previous, current) =>
                current is ModelOperationResult || current is ModelLoaded,
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
                modelIdController.value =
                    TextEditingValue(text: state.model.modelId);
                nameController.value = TextEditingValue(text: state.model.name);
                if (state.model.description != null) {
                  descriptionController.value =
                      TextEditingValue(text: state.model.description!);
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
                    maxContextController.value = TextEditingValue(
                        text: state.model.meta!.maxContext.toString());
                  }

                  if (state.model.meta!.inputPrice != null) {
                    inputPriceController.value = TextEditingValue(
                        text: state.model.meta!.inputPrice.toString());
                  }

                  if (state.model.meta!.outputPrice != null) {
                    outputPriceController.value = TextEditingValue(
                        text: state.model.meta!.outputPrice.toString());
                  }

                  promptController.value =
                      TextEditingValue(text: state.model.meta!.prompt ?? '');
                  supportVision = state.model.meta!.vision ?? false;
                  restricted = state.model.meta!.restricted ?? false;
                }
              }

              setState(() {
                editLocked = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 20),
              child: Column(
                children: [
                  ColumnBlock(
                    children: [
                      EnhancedTextField(
                        labelText: '唯一标识',
                        customColors: customColors,
                        controller: modelIdController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: '请输入模型唯一标识',
                        maxLength: 100,
                        showCounter: false,
                        readOnly: true,
                      ),
                      EnhancedTextField(
                        labelText: '名称',
                        customColors: customColors,
                        controller: nameController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: '请输入模型名称',
                        maxLength: 100,
                        showCounter: false,
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
                                image: avatarUrl == null
                                    ? null
                                    : DecorationImage(
                                        image: (avatarUrl!.startsWith('http')
                                            ? CachedNetworkImageProviderEnhanced(
                                                avatarUrl!)
                                            : FileImage(File(
                                                avatarUrl!))) as ImageProvider,
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
                        labelText: '描述',
                        customColors: customColors,
                        controller: descriptionController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: '可选',
                        maxLength: 255,
                        showCounter: false,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  ColumnBlock(
                    children: [
                      EnhancedTextField(
                        labelText: '输入价格',
                        customColors: customColors,
                        controller: inputPriceController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: '可选',
                        showCounter: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textDirection: TextDirection.rtl,
                        suffixIcon: Container(
                          width: 110,
                          alignment: Alignment.center,
                          child: Text(
                            '智慧果/1K Token',
                            style: TextStyle(
                                color: customColors.weakTextColor,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      EnhancedTextField(
                        labelText: '输出价格',
                        customColors: customColors,
                        controller: outputPriceController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: '可选',
                        showCounter: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textDirection: TextDirection.rtl,
                        suffixIcon: Container(
                          width: 110,
                          alignment: Alignment.center,
                          child: Text(
                            '智慧果/1K Token',
                            style: TextStyle(
                                color: customColors.weakTextColor,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      EnhancedTextField(
                        labelText: '输入限制',
                        customColors: customColors,
                        controller: maxContextController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: '最大上下文减掉预期的输出长度',
                        showCounter: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textDirection: TextDirection.rtl,
                        suffixIcon: Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Text(
                            'Token',
                            style: TextStyle(
                                color: customColors.weakTextColor,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var i = 0; i < providers.length; i++)
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            const SizedBox(width: 10),
                            SlidableAction(
                              label: AppLocale.delete.getString(context),
                              borderRadius: BorderRadius.circular(
                                  customColors.borderRadius ?? 8),
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              onPressed: (_) {
                                if (providers.length == 1) {
                                  showErrorMessage('至少需要一个渠道');
                                  return;
                                }

                                openConfirmDialog(
                                  context,
                                  AppLocale.confirmToDeleteRoom
                                      .getString(context),
                                  () {
                                    setState(() {
                                      providers.removeAt(i);
                                    });
                                  },
                                  danger: true,
                                );
                              },
                            ),
                          ],
                        ),
                        child: ColumnBlock(
                          margin: const EdgeInsets.all(0),
                          children: [
                            EnhancedInput(
                              title: Text(
                                '渠道',
                                style: TextStyle(
                                  color: customColors.textfieldLabelColor,
                                  fontSize: 16,
                                ),
                              ),
                              value: Text(
                                buildChannelName(providers[i]),
                                style: TextStyle(
                                  color: customColors.textfieldValueColor,
                                  fontSize: 16,
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
                                                '${e.id == null ? '【系统】' : ''}${e.name}'),
                                            e,
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  (value) {
                                    setState(() {
                                      providers[i].id = value.value.id;
                                      if (value.value.id == null) {
                                        providers[i].name = value.value.type;
                                      }
                                    });
                                    return true;
                                  },
                                  heightFactor: 0.5,
                                  value: providers[i],
                                );
                              },
                            ),
                            EnhancedTextField(
                              labelText: '模型重写',
                              labelFontSize: 12,
                              customColors: customColors,
                              textAlignVertical: TextAlignVertical.top,
                              hintText: '可选',
                              maxLength: 100,
                              showCounter: false,
                              initValue: providers[i].modelRewrite,
                              onChanged: (value) {
                                setState(() {
                                  providers[i].modelRewrite = value;
                                });
                              },
                              labelHelpWidget: InkWell(
                                onTap: () {
                                  showBeautyDialog(
                                    context,
                                    type: QuickAlertType.info,
                                    text:
                                        '渠道对应的模型标识和这里的 ID 不一致时，调用渠道接口时将会自动将模型替换为这里配置的值。',
                                    confirmBtnText:
                                        AppLocale.gotIt.getString(context),
                                    showCancelBtn: false,
                                  );
                                },
                                child: Icon(
                                  Icons.help_outline,
                                  size: 16,
                                  color: customColors.weakLinkColor
                                      ?.withAlpha(150),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  WeakTextButton(
                    title: '添加渠道',
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
                        EnhancedTextField(
                          labelText: '简称',
                          customColors: customColors,
                          controller: shortNameController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: '请输入模型简称',
                          maxLength: 100,
                          showCounter: false,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '启用',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '视觉能力',
                              style: TextStyle(fontSize: 16),
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
                                  '受限模型',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    showBeautyDialog(
                                      context,
                                      type: QuickAlertType.info,
                                      text: '受限模型是指因政策因素，不能在中国大陆地区使用的模型。',
                                      confirmBtnText:
                                          AppLocale.gotIt.getString(context),
                                      showCancelBtn: false,
                                    );
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 16,
                                    color: customColors.weakLinkColor
                                        ?.withAlpha(150),
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
                          labelText: '系统提示语',
                          customColors: customColors,
                          controller: promptController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: '全局系统提示语',
                          maxLength: 2000,
                          maxLines: 3,
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
                          showAdvancedOptions
                              ? Icons.unfold_less
                              : Icons.unfold_more,
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
                              ? const Icon(Icons.lock,
                                  color: Colors.white, size: 16)
                              : const Icon(Icons.lock_open,
                                  color: Colors.white, size: 16),
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
    );
  }

  /// 提交
  void onSubmit() async {
    if (editLocked) {
      return;
    }

    if (nameController.text.isEmpty) {
      showErrorMessage('请输入模型名称');
      return;
    }

    final ps = providers.where((e) => e.id != null || e.name != null).toList();
    if (ps.isEmpty) {
      showErrorMessage('至少需要一个渠道');
      return;
    }

    if (avatarUrl != null &&
        (!avatarUrl!.startsWith('http://') &&
            !avatarUrl!.startsWith('https://'))) {
      final cancel = BotToast.showCustomLoading(
        toastBuilder: (cancel) {
          return const LoadingIndicator(
            message: '正在上传头像，请稍后...',
          );
        },
        allowClick: false,
      );

      try {
        final res = await ImageUploader(widget.setting)
            .upload(avatarUrl!, usage: 'avatar');
        avatarUrl = res.url;
      } catch (e) {
        showErrorMessage('上传头像失败');
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
        prompt: promptController.text,
        vision: supportVision,
        restricted: restricted,
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
            orElse: () => AdminChannel(name: '未知', type: ''),
          )
          .display;
    }

    return '请选择';
  }
}
