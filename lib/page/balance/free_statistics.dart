import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';

class FreeStatisticsPage extends StatefulWidget {
  final SettingRepository setting;

  const FreeStatisticsPage({super.key, required this.setting});

  @override
  State<FreeStatisticsPage> createState() => _FreeStatisticsPageState();
}

class _FreeStatisticsPageState extends State<FreeStatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FreeCountBloc>().add(FreeCountReloadAllEvent(checkSigninStatus: true));
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
            AppLocale.freeQuota.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
          enabled: false,
          child: RefreshIndicator(
            displacement: 20,
            color: customColors.linkColor,
            onRefresh: () async {
              context.read<FreeCountBloc>().add(FreeCountReloadAllEvent());
            },
            child: SafeArea(
              child: SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: BlocConsumer<FreeCountBloc, FreeCountState>(
                    listenWhen: (previous, current) => current is FreeCountLoadedState,
                    listener: (BuildContext context, FreeCountState state) {
                      if (state is FreeCountLoadedState) {
                        if (state.needSignin) {
                          showBeautyDialog(
                            context,
                            type: QuickAlertType.warning,
                            text: AppLocale.freeModelNeedSignIn.getString(context),
                            confirmBtnText: AppLocale.signIn.getString(context),
                            onConfirmBtnTap: () {
                              context.pop();
                              context.go('/login');
                            },
                            showCancelBtn: true,
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is FreeCountLoadedState) {
                        if (state.counts.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: MessageBox(
                                message: AppLocale.noFreeModel.getString(context),
                                type: MessageBoxType.warning,
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              MessageBox(
                                message: AppLocale.freeModelInfo.getString(context),
                                type: MessageBoxType.info,
                              ),
                              const SizedBox(height: 10),
                              ColumnBlock(
                                innerPanding: 5,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                            child: Text(
                                          'Model',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        )),
                                        Row(
                                          children: [
                                            Text(
                                              AppLocale.todayLeft.getString(context),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...state.counts.map((e) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(
                                                  e.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (e.info != null && e.info != '') const SizedBox(width: 5),
                                                if (e.info != null && e.info != '')
                                                  InkWell(
                                                    onTap: () {
                                                      showBeautyDialog(
                                                        context,
                                                        type: QuickAlertType.info,
                                                        text: e.info ?? '',
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
                                          ),
                                          buildLeftCountWidget(
                                            leftCount: e.leftCount,
                                            maxCount: e.maxCount,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      return const Center(child: LoadingIndicator());
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLeftCountWidget({required int leftCount, required int maxCount}) {
    return Text(
      '$leftCount',
      style: const TextStyle(
        fontSize: 14,
      ),
    );
  }
}
