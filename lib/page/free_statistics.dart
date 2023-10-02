import 'package:askaide/bloc/free_count_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
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

    context.read<FreeCountBloc>().add(FreeCountReloadAllEvent());
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: const Text(
          '我的免费额度',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<FreeCountBloc>().add(FreeCountReloadAllEvent());
            },
            child: BlocBuilder<FreeCountBloc, FreeCountState>(
              builder: (context, state) {
                if (state is FreeCountLoadedState) {
                  if (state.counts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: MessageBox(
                          message: '当前无可用的免费模型。',
                          type: MessageBoxType.warning,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const MessageBox(
                          message: '免费额度是指模型每天可以免费使用的次数，每天 00:00 自动重置（北京时间）。',
                          type: MessageBoxType.info,
                        ),
                        const SizedBox(height: 10),
                        ColumnBlock(
                          innerPanding: 5,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    '模型名称',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  Row(
                                    children: [
                                      Text(
                                        '免费次数',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ...state.counts.map((e) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(e.name),
                                          if (e.info != null && e.info != '')
                                            const SizedBox(width: 5),
                                          if (e.info != null && e.info != '')
                                            InkWell(
                                              onTap: () {
                                                showBeautyDialog(
                                                  context,
                                                  type: QuickAlertType.info,
                                                  text: e.info ?? '',
                                                  confirmBtnText: AppLocale
                                                      .gotIt
                                                      .getString(context),
                                                  showCancelBtn: false,
                                                );
                                              },
                                              child: Icon(
                                                Icons.help_outline,
                                                size: 16,
                                                color: customColors
                                                    .weakLinkColor
                                                    ?.withAlpha(150),
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
    );
  }

  Widget buildLeftCountWidget({required int leftCount, required int maxCount}) {
    if (leftCount <= 0 && maxCount > 0) {
      return Text(
        leftCount.toString(),
        style: const TextStyle(color: Colors.red),
      );
    }

    return Text(leftCount.toString());
  }
}
