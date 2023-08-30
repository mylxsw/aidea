import 'dart:io';

import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';

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
    File('${Directory.systemTemp.path}/log.txt').exists().then(
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
          title: const Text(
            '故障日志',
            style: TextStyle(
              fontSize: CustomSize.appBarTitleSize,
            ),
          ),
          centerTitle: true,
          actions: [
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
                  '上报',
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
