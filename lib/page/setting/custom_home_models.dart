import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/model_indicator.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/model.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class CustomHomeModelsPage extends StatefulWidget {
  final SettingRepository setting;
  const CustomHomeModelsPage({super.key, required this.setting});

  @override
  State<CustomHomeModelsPage> createState() => _CustomHomeModelsPageState();
}

class _CustomHomeModelsPageState extends State<CustomHomeModelsPage> {
  List<HomeModelV2> models = [
    HomeModelV2(
      type: 'model',
      id: 'openai:gpt-3.5-turbo',
      supportVision: false,
      name: 'GPT-3.5',
    ),
    HomeModelV2(
      type: 'model',
      id: 'openai:gpt-4',
      supportVision: false,
      name: 'GPT-4',
    ),
    HomeModelV2(
      type: 'model',
      id: '',
      supportVision: false,
      name: 'Unset',
    ),
  ];

  @override
  void initState() {
    if (Ability().homeModels.isNotEmpty) {
      models = Ability().homeModels;

      if (models.length < 3) {
        models.add(HomeModelV2(
          type: 'model',
          id: '',
          supportVision: false,
          name: 'Unset',
        ));
      }
    }

    APIServer().capabilities(cache: false).then((cap) {
      Ability().updateCapabilities(cap);

      if (cap.homeModels.isNotEmpty) {
        models = cap.homeModels;

        if (models.length < 3) {
          models.add(HomeModelV2(
            type: 'model',
            id: '',
            supportVision: false,
            name: 'Unset',
          ));
        }

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

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
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
                  message: '用于设置聊一聊中的常用模型。模型 3 为可选项，长按可重置',
                  type: MessageBoxType.info,
                ),
                const SizedBox(height: 10),
                ColumnBlock(
                  innerPanding: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  children: [
                    for (var i = 0; i < models.length; i++)
                      GestureDetector(
                        onTap: () {
                          openSelectCustomModelDialog(
                            context,
                            (selected) {
                              setState(() {
                                models[i] = selected;
                              });
                            },
                            initValue: models[i].id,
                          );
                        },
                        onLongPress: () {
                          if (models[i].id.isNotEmpty && i == models.length - 1) {
                            openConfirmDialog(
                              context,
                              '确认重置该模型？',
                              () {
                                setState(() {
                                  models[i] = HomeModelV2(
                                    type: 'model',
                                    id: '',
                                    supportVision: false,
                                    name: 'Unset',
                                  );
                                });
                              },
                              confirmText: AppLocale.reset.getString(context),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: iconAndColors[i].color,
                                borderRadius: CustomSize.borderRadius,
                              ),
                              child: ModelIndicator(
                                model: models[i],
                                iconAndColor: iconAndColors[i],
                                selected: true,
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
                      final selectedModels = models.where((e) => e.id != '').map((e) => e.uniqueKey).toList();
                      await APIServer().updateCustomHomeModelsV2(models: selectedModels);

                      APIServer().capabilities(cache: false).then((value) => Ability().updateCapabilities(value));

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
      ),
    );
  }
}

void openSelectCustomModelDialog(
  BuildContext context,
  Function(HomeModelV2 selected) onSelected, {
  String? initValue,
}) {
  openModalBottomSheet(
    context,
    (context) {
      return FutureBuilder(
          future: APIServer().customHomeModelsV2(cache: false),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              showErrorMessage(resolveError(context, snapshot.error!));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return HomeModelItem(
              models: snapshot.data!,
              onSelected: (selected) {
                onSelected(selected);
                context.pop();
              },
              initValue: initValue,
            );
          });
    },
    heightFactor: 0.9,
  );
}

class HomeModelItem extends StatelessWidget {
  final List<HomeModelV2> models;
  final Function(HomeModelV2 selected) onSelected;
  final String? initValue;

  const HomeModelItem({
    super.key,
    required this.models,
    required this.onSelected,
    this.initValue,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    var modelsByType = <String, List<HomeModelV2>>{
      'model': [],
      'room_gallery': [],
      'rooms': [],
    };

    for (var model in models) {
      modelsByType[model.type]!.add(model);
    }

    return models.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 15),
            child: DefaultTabController(
              length: modelsByType.length,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    indicatorColor: customColors.linkColor,
                    labelColor: customColors.linkColor,
                    unselectedLabelColor: customColors.textfieldLabelColor,
                    tabs: const [
                      Tab(text: '模型'),
                      Tab(text: '内置数字人'),
                      Tab(text: '我的数字人'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildTabView(
                          context,
                          customColors,
                          models.where((e) => e.type == 'model').toList(),
                        ),
                        buildTabView(
                          context,
                          customColors,
                          models.where((e) => e.type == 'room_gallery').toList(),
                        ),
                        buildTabView(
                          context,
                          customColors,
                          models.where((e) => e.type == 'rooms').toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : const Center(
            child: Text(
              '没有可用模型\n请先登录或者配置 OpenAI 的 Keys',
              textAlign: TextAlign.center,
            ),
          );
  }

  Widget buildTabView(
    BuildContext context,
    CustomColors customColors,
    List<HomeModelV2> models,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: models.length,
      itemBuilder: (context, i) {
        var item = models[i];
        if (item.avatarUrl == null) {
          Logger.instance.w(item.toJson());
        }

        return ListTile(
          title: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAvatar(avatarUrl: item.avatarUrl, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Row(children: [
                      Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  width: 10,
                  child: Icon(
                    Icons.check,
                    color: initValue == item.id ? customColors.linkColor : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(item);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 1,
          color: customColors.columnBlockDividerColor,
        );
      },
    );
  }

  Widget buildAvatar({String? avatarUrl, int? id, int size = 30}) {
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return RemoteAvatar(
        avatarUrl: imageURL(avatarUrl, qiniuImageTypeAvatar),
        size: size,
      );
    }

    return RandomAvatar(
      id: id ?? 0,
      size: size,
      usage: Ability().isUserLogon() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }
}
