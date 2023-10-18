import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat_room_create.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/model_indicator.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class CustomHomeModelsPage extends StatefulWidget {
  final SettingRepository setting;
  const CustomHomeModelsPage({super.key, required this.setting});

  @override
  State<CustomHomeModelsPage> createState() => _CustomHomeModelsPageState();
}

class _CustomHomeModelsPageState extends State<CustomHomeModelsPage> {
  List<ModelIndicatorInfo> models = [
    ModelIndicatorInfo(
      modelId: "openai:gpt-3.5-turbo",
      modelName: 'GPT-3.5',
      description: '速度快，成本低',
      icon: Icons.bolt,
      activeColor: Colors.green,
    ),
    ModelIndicatorInfo(
      modelId: "openai:gpt-4",
      modelName: 'GPT-4',
      description: '能力强，更精准',
      icon: Icons.auto_awesome,
      activeColor: const Color.fromARGB(255, 120, 73, 223),
    ),
  ];

  @override
  void initState() {
    if (Ability().homeModels.isNotEmpty) {
      models = Ability()
          .homeModels
          .map((e) => ModelIndicatorInfo(
                modelId: e.modelId,
                modelName: e.name,
                description: e.desc,
                icon: e.powerful ? Icons.auto_awesome : Icons.bolt,
                activeColor: stringToColor(e.color),
              ))
          .toList();
    }

    APIServer().capabilities().then((cap) {
      Ability().updateCapabilities(cap);

      if (cap.homeModels.isNotEmpty) {
        models = cap.homeModels
            .map((e) => ModelIndicatorInfo(
                  modelId: e.modelId,
                  modelName: e.name,
                  description: e.desc,
                  icon: e.powerful ? Icons.auto_awesome : Icons.bolt,
                  activeColor: stringToColor(e.color),
                ))
            .toList();

        if (mounted) {
          setState(() {});
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: Text(
          AppLocale.customHomeModels.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const MessageBox(
                message: '用于设置聊一聊功能所选用的常用模型。',
                type: MessageBoxType.info,
              ),
              const SizedBox(height: 10),
              ColumnBlock(
                innerPanding: 5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                children: [
                  for (var i = 0; i < models.length; i++)
                    GestureDetector(
                      onTap: () {
                        openSelectModelDialog(
                          context,
                          (selected) {
                            models[i].modelId = selected.id;
                            models[i].modelName =
                                selected.shortName ?? selected.name;
                            setState(() {});
                          },
                          initValue: models[i].modelId,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: models[i].activeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ModelIndicator(
                              model: models[i],
                              selected: true,
                              showDescription: false,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Text(
                                '模型 ${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              EnhancedButton(
                title: AppLocale.save.getString(context),
                onPressed: () async {
                  final cancelLoading = BotToast.showCustomLoading(
                    toastBuilder: (cancel) {
                      return LoadingIndicator(
                        message: AppLocale.processingWait.getString(context),
                      );
                    },
                    allowClick: false,
                    duration: const Duration(seconds: 120),
                  );

                  try {
                    final selectedModels =
                        models.map((e) => e.modelId).toList();
                    await APIServer()
                        .updateCustomHomeModels(models: selectedModels);

                    APIServer()
                        .capabilities(cache: false)
                        .then((value) => Ability().updateCapabilities(value));

                    showSuccessMessage(
                        // ignore: use_build_context_synchronously
                        AppLocale.operateSuccess.getString(context));
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showErrorMessageEnhanced(context, e);
                  } finally {
                    cancelLoading();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
