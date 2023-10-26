import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/random_avatar.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/group.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class GroupCreatePage extends StatefulWidget {
  final SettingRepository setting;

  const GroupCreatePage({super.key, required this.setting});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  List<Model> models = [];
  List<Model> selectedModels = [];

  Function? globalLoadingCancel;

  @override
  void initState() {
    super.initState();

    // 加载模型
    APIServer().models().then((value) {
      setState(() {
        models = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '发起群聊',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
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
                context.pop();
              } else {
                showErrorMessageEnhanced(context,
                    state.error ?? AppLocale.operateFailed.getString(context));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                  child: Text(
                    '选择参与群聊的成员',
                    style: TextStyle(
                      fontSize: 14,
                      color: customColors.weakLinkColor,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: models.length,
                    itemBuilder: (context, i) {
                      var item = models[i];
                      return ListTile(
                        title: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAvatar(avatarUrl: item.avatarUrl, size: 40),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.center,
                                child: Text(item.name),
                              )),
                              SizedBox(
                                width: 10,
                                child: Icon(
                                  Icons.check,
                                  color: selectedModels.contains(item)
                                      ? customColors.linkColor
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (selectedModels.contains(item)) {
                              selectedModels.remove(item);
                            } else {
                              selectedModels.add(item);
                            }
                          });
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                        color: customColors.columnBlockDividerColor,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),
                // 保存按钮
                buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: EnhancedButton(
              title: AppLocale.ok.getString(context) +
                  (selectedModels.isNotEmpty
                      ? ' (x${selectedModels.length})'
                      : ''),
              backgroundColor: selectedModels.isEmpty ? Colors.grey : null,
              onPressed: () async {
                if (selectedModels.isEmpty) {
                  return;
                }

                globalLoadingCancel = BotToast.showCustomLoading(
                  toastBuilder: (cancel) {
                    return LoadingIndicator(
                      message: AppLocale.processingWait.getString(context),
                    );
                  },
                  allowClick: false,
                  duration: const Duration(seconds: 120),
                );

                try {
                  if (context.mounted) {
                    context.read<RoomBloc>().add(
                          GroupRoomCreateEvent(
                            name: selectedModels
                                .map((e) => e.shortName)
                                .take(3)
                                .join("、"),
                            members: selectedModels
                                .map((e) => GroupMember(
                                    modelId: e.realModelId,
                                    modelName: e.shortName))
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
}
