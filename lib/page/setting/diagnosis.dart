import 'dart:io';

import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/path.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:quickalert/quickalert.dart';
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
    if (!PlatformTool.isWeb()) {
      File(PathHelper().getLogfilePath).exists().then(
            (exist) => {
              if (exist)
                File(PathHelper().getLogfilePath).readAsString().then((value) {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        backgroundColor: customColors.backgroundColor,
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
                  'This action will erase all settings and data, do you want to proceed?',
                  () async {
                    final databasePath = (await databaseFactory.getDatabasesPath()).replaceAll('\\', '/');

                    Logger.instance.d('databasePath: $databasePath');

                    try {
                      // 删除数据库目录
                      await Directory(databasePath).delete(
                        recursive: true,
                      );

                      showSuccessMessage(
                        // ignore: use_build_context_synchronously
                        AppLocale.operateSuccess.getString(context),
                      );

                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    } catch (e) {
                      Logger.instance.e(e);
                      showBeautyDialog(
                        // ignore: use_build_context_synchronously
                        context,
                        type: QuickAlertType.error,
                        text:
                            'Data file deletion failed. Please close the application first, manually delete the directory $databasePath, and then restart the application.',
                      );
                    }
                  },
                  danger: true,
                );
              },
              child: Text(
                '重置系统',
                style: TextStyle(
                  color: isUploaded ? customColors.weakTextColor?.withAlpha(100) : customColors.weakLinkColor,
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

                  APIServer().diagnosisUpload(data: diagnosisInfo).then((value) {
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
                    color: isUploaded ? customColors.weakTextColor?.withAlpha(100) : customColors.weakLinkColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
          enabled: false,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: [
                  ColumnBlock(
                    innerPanding: 5,
                    padding: const EdgeInsets.all(10),
                    children: [
                      Text(
                        'Server: ${APIServer().url}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'User ID: ${APIServer().localUserID()}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      const Text(
                        'Client Version: $clientVersion',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'OS: ${PlatformTool.operatingSystem()} | ${PlatformTool.operatingSystemVersion()}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'OpenAI Custom: ${Ability().enableLocalOpenAI}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      FutureBuilder(
                        future: databaseFactory.getDatabasesPath(),
                        builder: (context, snapshot) {
                          return Text(
                            'Local Database: ${snapshot.data?.replaceAll('\\', '/')}',
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                      Text(
                        'Log File: ${PathHelper().getLogfilePath}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Cache Directory: ${PathHelper().getCachePath}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Main Directory: ${PathHelper().getHomePath}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  ColumnBlock(
                    children: [
                      Text(
                        diagnosisInfo,
                        style: const TextStyle(
                          fontSize: 10,
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
}
