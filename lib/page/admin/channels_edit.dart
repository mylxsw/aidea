import 'package:askaide/bloc/channel_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/admin/channels.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ChannelEditPage extends StatefulWidget {
  final SettingRepository setting;
  final int channelId;
  const ChannelEditPage({
    super.key,
    required this.setting,
    required this.channelId,
  });

  @override
  State<ChannelEditPage> createState() => _ChannelEditPageState();
}

class _ChannelEditPageState extends State<ChannelEditPage> {
  // 渠道类型
  List<AdminChannelType> channelTypes = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController serverController = TextEditingController();
  final TextEditingController secretController = TextEditingController();

  /// 当前选中的渠道类型
  String? selectedChannelType;

  /// 用于控制是否显示高级选项
  bool showAdvancedOptions = false;

  /// 是否使用代理
  bool usingProxy = false;

  /// 是否是 Azure API
  bool openaiAzure = false;

  /// OpenAI Azure API 版本
  final TextEditingController azureAPIVersionController = TextEditingController();

  /// 是否锁定编辑
  bool editLocked = true;

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    serverController.dispose();
    secretController.dispose();
    azureAPIVersionController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // 加载渠道类型
    APIServer().adminChannelTypes().then((value) {
      if (context.mounted) {
        setState(() {
          channelTypes = value.where((e) => e.dynamicType).toList();
        });
      }
    });

    // 加载渠道信息
    context.read<ChannelBloc>().add(ChannelLoadEvent(widget.channelId));

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
            'Edit Channel',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: BlocListener<ChannelBloc, ChannelState>(
            listenWhen: (previous, current) => current is ChannelOperationResult || current is ChannelLoaded,
            listener: (context, state) {
              if (state is ChannelOperationResult) {
                if (state.success) {
                  showSuccessMessage(state.message);
                  context.read<ChannelBloc>().add(ChannelLoadEvent(widget.channelId));
                } else {
                  showErrorMessage(state.message);
                }
              } else if (state is ChannelLoaded) {
                nameController.text = state.channel.name;
                selectedChannelType = state.channel.type;
                serverController.text = state.channel.server ?? '';
                secretController.text = state.channel.secret ?? '';
                usingProxy = state.channel.meta?.usingProxy ?? false;
                openaiAzure = state.channel.meta?.openaiAzure ?? false;
                azureAPIVersionController.text = state.channel.meta?.openaiAzureAPIVersion ?? '';

                setState(() {
                  editLocked = false;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ColumnBlock(
                    children: [
                      EnhancedTextField(
                        labelText: 'Name',
                        customColors: customColors,
                        controller: nameController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: 'Enter channel name',
                        maxLength: 100,
                        showCounter: false,
                      ),
                      EnhancedInput(
                        title: Text(
                          'Type',
                          style: TextStyle(
                            color: customColors.textfieldLabelColor,
                            fontSize: 16,
                          ),
                        ),
                        value: Text(
                          buildSelectedChannelTypeText(),
                          style: TextStyle(
                            color: customColors.textfieldValueColor,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          openListSelectDialog(
                            context,
                            channelTypes.map((e) => SelectorItem(Text(e.text), e.name)).toList(),
                            (value) {
                              setState(() {
                                selectedChannelType = value.value;
                              });
                              return true;
                            },
                            heightFactor: 0.5,
                            value: selectedChannelType,
                          );
                        },
                      ),
                      EnhancedTextField(
                        labelText: 'Server',
                        customColors: customColors,
                        controller: serverController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: 'https://api.openai.com/v1',
                        maxLength: 255,
                        showCounter: false,
                      ),
                      EnhancedTextField(
                        labelText: 'API Key',
                        customColors: customColors,
                        controller: secretController,
                        textAlignVertical: TextAlignVertical.top,
                        hintText: 'Enter API Key',
                        maxLength: 2048,
                        obscureText: true,
                        showCounter: false,
                      ),
                    ],
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
                              'Use Proxy',
                              style: TextStyle(fontSize: 16),
                            ),
                            CupertinoSwitch(
                              activeColor: customColors.linkColor,
                              value: usingProxy,
                              onChanged: (value) {
                                setState(() {
                                  usingProxy = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Azure Mode',
                              style: TextStyle(fontSize: 16),
                            ),
                            CupertinoSwitch(
                              activeColor: customColors.linkColor,
                              value: openaiAzure,
                              onChanged: (value) {
                                setState(() {
                                  openaiAzure = value;
                                });
                              },
                            ),
                          ],
                        ),
                        EnhancedTextField(
                          labelText: 'Version',
                          customColors: customColors,
                          controller: azureAPIVersionController,
                          textAlignVertical: TextAlignVertical.top,
                          hintText: '2023-05-15',
                          maxLength: 30,
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
    );
  }

  /// 提交
  void onSubmit() {
    if (editLocked) {
      return;
    }

    if (nameController.text.isEmpty) {
      showErrorMessage('Please enter a channel name');
      return;
    }

    if (selectedChannelType == null) {
      showErrorMessage('Please select channel type');
      return;
    }

    if (serverController.text.isEmpty) {
      showErrorMessage('Please enter the server address');
      return;
    }

    if (!serverController.text.startsWith('http://') && !serverController.text.startsWith('https://')) {
      showErrorMessage('The server address format is incorrect');
      return;
    }

    final req = AdminChannelUpdateReq(
      name: nameController.text,
      type: selectedChannelType!,
      server: serverController.text,
      secret: secretController.text,
      meta: AdminChannelMeta(
        usingProxy: usingProxy,
        openaiAzure: openaiAzure,
        openaiAzureAPIVersion: azureAPIVersionController.text,
      ),
    );

    context.read<ChannelBloc>().add(ChannelUpdateEvent(widget.channelId, req));
  }

  /// 生成选中的渠道类型文本
  String buildSelectedChannelTypeText() {
    if (selectedChannelType == null) {
      return 'Select';
    }

    return channelTypes.firstWhere((element) => element.name == selectedChannelType).text;
  }
}
