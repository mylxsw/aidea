import 'package:askaide/bloc/user_api_keys_bloc.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
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

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
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
                  message:
                      'You can use API Key to access your data in other applications, and the protocol is fully compatible with OpenAI\'s official API.',
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
                        confirmBtnText: 'Copy to clipboard',
                        onConfirmBtnTap: () {
                          FlutterClipboard.copy(state.key.token).then((value) {
                            showSuccessMessage('Copied to clipboard');
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
                              'You haven\'t created any API Key yet.',
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
                            decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  const SizedBox(width: 10),
                                  SlidableAction(
                                    label: AppLocale.delete.getString(context),
                                    borderRadius: CustomSize.borderRadiusAll,
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    onPressed: (_) {
                                      openConfirmDialog(
                                        context,
                                        AppLocale.confirmDelete.getString(context),
                                        () {
                                          context.read<UserApiKeysBloc>().add(UserApiKeyDelete(item.id));
                                        },
                                        danger: true,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              child: Material(
                                color: customColors.backgroundColor?.withAlpha(200),
                                borderRadius: const BorderRadius.all(CustomSize.radius),
                                child: InkWell(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    shape: RoundedRectangleBorder(borderRadius: CustomSize.borderRadius),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            color: customColors.weakTextColor?.withAlpha(65),
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
                                          color: customColors.weakTextColor?.withAlpha(150),
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    dense: true,
                                    onTap: () {
                                      cancelDialog = BotToast.showCustomLoading(
                                        toastBuilder: (cancel) {
                                          return LoadingIndicator(
                                            message: AppLocale.imageUploading.getString(context),
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
      ),
    );
  }
}
