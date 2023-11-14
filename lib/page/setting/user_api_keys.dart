import 'package:askaide/bloc/user_api_keys_bloc.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';

class UserAPIKeysScreen extends StatefulWidget {
  final SettingRepository setting;

  const UserAPIKeysScreen({super.key, required this.setting});

  @override
  State<UserAPIKeysScreen> createState() => _UserAPIKeysScreenState();
}

class _UserAPIKeysScreenState extends State<UserAPIKeysScreen> {
  Function? cancelDialog;

  @override
  void initState() {
    super.initState();
    context.read<UserApiKeysBloc>().add(UserApiKeysLoad());
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: Text(
          AppLocale.userApiKeys.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              openTextFieldDialog(
                context,
                title: 'API Key',
                hint: 'API Key 名称',
                onSubmit: (value) {
                  context.read<UserApiKeysBloc>().add(UserApiKeyCreate(value));
                  return true;
                },
              );
            },
          ),
        ],
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
                message: '你可以在其它应用中使用 API Key 访问你的数据，接口协议全面兼容 OpenAI 官方 API。',
                type: MessageBoxType.info,
              ),
              const SizedBox(height: 10),
              BlocConsumer<UserApiKeysBloc, UserApiKeysState>(
                listener: (context, state) {
                  if (state is UserApiKeyLoaded) {
                    showBeautyDialog(
                      context,
                      type: QuickAlertType.success,
                      title: 'API Key',
                      text: state.key.token,
                      confirmBtnText: '复制到剪切板',
                      onConfirmBtnTap: () {
                        FlutterClipboard.copy(state.key.token).then((value) {
                          showSuccessMessage('已复制到剪贴板');
                          context.pop();
                        });

                        cancelDialog?.call();
                      },
                      showCancelBtn: true,
                      onCancelBtnTap: () => context.pop(),
                      barrierDismissible: true,
                    );
                  }
                },
                buildWhen: (previous, current) => current is UserApiKeysLoaded,
                builder: (context, state) {
                  if (state is UserApiKeysLoaded) {
                    if (state.keys.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 50),
                        alignment: Alignment.center,
                        child: Center(
                          child: Text(
                            '你还没有创建任何 API Key',
                            style: TextStyle(
                              fontSize: 14,
                              color: customColors.weakTextColor,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.keys.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = state.keys[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                const SizedBox(width: 10),
                                SlidableAction(
                                  label: AppLocale.delete.getString(context),
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  onPressed: (_) {
                                    openConfirmDialog(
                                      context,
                                      AppLocale.confirmDelete
                                          .getString(context),
                                      () {
                                        context
                                            .read<UserApiKeysBloc>()
                                            .add(UserApiKeyDelete(item.id));
                                      },
                                      danger: true,
                                    );
                                  },
                                ),
                              ],
                            ),
                            child: Material(
                              color:
                                  customColors.backgroundColor?.withAlpha(200),
                              borderRadius: BorderRadius.all(
                                Radius.circular(customColors.borderRadius ?? 8),
                              ),
                              child: InkWell(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        customColors.borderRadius ?? 8),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: customColors.weakTextColor,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      Text(
                                        humanTime(DateTime.now()),
                                        style: TextStyle(
                                          color: customColors.weakTextColor
                                              ?.withAlpha(65),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      item.token,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: customColors.weakTextColor
                                            ?.withAlpha(150),
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    cancelDialog = BotToast.showCustomLoading(
                                      toastBuilder: (cancel) {
                                        return const LoadingIndicator(
                                          message: "正在上传图片，请稍后...",
                                        );
                                      },
                                      allowClick: false,
                                    );

                                    context.read<UserApiKeysBloc>().add(
                                          UserApiKeyLoad(item.id),
                                        );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(child: LoadingIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
