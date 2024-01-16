import 'dart:io';

import 'package:askaide/helper/env.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DiagnosisScreen extends StatefulWidget {
  final SettingRepository setting;
  const DiagnosisScreen({super.key, required this.setting});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String diagnosisInfo = '';
  bool isUploaded = false;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    File('$getHomePath/aidea.log').exists().then(
          (exist) => {
            if (exist)
              File('${Directory.systemTemp.path}/log.txt')
                  .readAsString()
                  .then((value) {
                setState(() {
                  diagnosisInfo = value;
                });

                Future.delayed(const Duration(milliseconds: 100), () {
                  _controller.jumpTo(_controller.position.maxScrollExtent);
                });
              })
            else
              setState(() {
                diagnosisInfo = 'No log file found';
              })
          },
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: Text(
            AppLocale.errorLog.getString(context),
            style: const TextStyle(
              fontSize: CustomSize.appBarTitleSize,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                openConfirmDialog(
                  context,
                  '该操作将会清空所有设置和数据，是否继续？',
                  () async {
                    final databasePath =
                        await databaseFactory.getDatabasesPath();

                    Logger.instance.d('databasePath: $databasePath');

                    // 删除数据库目录
                    await Directory(databasePath).delete(
                      recursive: true,
                    );

                    showSuccessMessage(
                      // ignore: use_build_context_synchronously
                      AppLocale.operateSuccess.getString(context),
                    );

                    try {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    } catch (e) {
                      Logger.instance.e(e);
                      showErrorMessage('应用重启失败，请手动重启');
                    }
                  },
                  danger: true,
                );
              },
              child: Text(
                '重置系统',
                style: TextStyle(
                  color: isUploaded
                      ? customColors.weakTextColor?.withAlpha(100)
                      : customColors.weakLinkColor,
                  fontSize: 12,
                ),
              ),
            ),
            if (diagnosisInfo.isNotEmpty)
              TextButton(
                onPressed: () {
                  if (isUploaded) {
                    showSuccessMessage('已上报');
                    return;
                  }

                  APIServer()
                      .diagnosisUpload(data: diagnosisInfo)
                      .then((value) {
                    showSuccessMessage('上报成功');
                    setState(() {
                      isUploaded = true;
                    });
                  }).onError((error, stackTrace) {
                    showErrorMessageEnhanced(context, error!);
                  });
                },
                child: Text(
                  AppLocale.report.getString(context),
                  style: TextStyle(
                    color: isUploaded
                        ? customColors.weakTextColor?.withAlpha(100)
                        : customColors.weakLinkColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            controller: _controller,
            child: ColumnBlock(
              children: [
                Text(
                  diagnosisInfo,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
