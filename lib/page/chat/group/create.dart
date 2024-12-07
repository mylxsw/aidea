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
        models = value.where((e) => !e.disabled).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.createGroupChat.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: CustomSize.toolbarHeight,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: EnhancedButton(
              width: 50,
              height: 30,
              fontSize: 14,
              title: AppLocale.ok.getString(context),
              color: selectedModels.isEmpty ? customColors.weakTextColor : null,
              backgroundColor: selectedModels.isEmpty ? customColors.weakTextColor!.withAlpha(20) : null,
              onPressed: () {
                onSave(context);
              },
            ),
          ),
        ],
      ),
      backgroundColor: customColors.backgroundColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: BlocListener<RoomBloc, RoomState>(
          listenWhen: (previous, current) => current is GroupRoomUpdateResultState,
          listener: (context, state) {
            if (state is GroupRoomUpdateResultState) {
              globalLoadingCancel?.call();
              if (state.success) {
                showSuccessMessage(AppLocale.operateSuccess.getString(context));
                context.pop();
              } else {
                showErrorMessageEnhanced(context, state.error ?? AppLocale.operateFailed.getString(context));
              }
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 15, left: 20, bottom: 15),
                child: Text(
                  AppLocale.selectGroupMembers.getString(context),
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
                    return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      checkboxShape: const CircleBorder(),
                      activeColor: customColors.linkColor,
                      side: BorderSide(
                        color: customColors.weakTextColor!.withAlpha(100),
                      ),
                      title: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAvatar(avatarUrl: item.avatarUrl, size: 40),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(item.name),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (selected) {
                        setState(() {
                          if (selectedModels.contains(item)) {
                            selectedModels.remove(item);
                          } else {
                            selectedModels.add(item);
                          }
                        });
                      },
                      value: selectedModels.contains(item),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      color: customColors.columnBlockDividerColor?.withAlpha(200),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onSave(BuildContext context) {
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
                name: selectedModels.map((e) => e.shortName).take(3).join("、"),
                members:
                    selectedModels.map((e) => GroupMember(modelId: e.realModelId, modelName: e.shortName)).toList(),
              ),
            );
      }
    } catch (e) {
      globalLoadingCancel?.call();
      // ignore: use_build_context_synchronously
      showErrorMessageEnhanced(context, e);
    }
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
      usage: Ability().isUserLogon() ? AvatarUsage.room : AvatarUsage.legacy,
    );
  }
}
