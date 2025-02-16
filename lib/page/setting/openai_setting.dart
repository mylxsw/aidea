import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/message_box.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class OpenAISettingScreen extends StatefulWidget {
  final SettingRepository settings;
  final String? source;
  const OpenAISettingScreen({
    super.key,
    required this.settings,
    this.source,
  });

  @override
  State<OpenAISettingScreen> createState() => _OpenAISettingScreenState();
}

class _OpenAISettingScreenState extends State<OpenAISettingScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  bool enableOpenAISelfHosted = true;
  bool? verifySuccess;

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.settings.stringDefault(settingOpenAIAPIToken, '');
    _organizationController.text = widget.settings.stringDefault(settingOpenAIOrganization, '');
    _urlController.text = widget.settings.stringDefault(settingOpenAIURL, '');
    if (widget.source == 'setting') {
      enableOpenAISelfHosted = widget.settings.boolDefault(settingOpenAISelfHosted, false);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _organizationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'OpenAI Setting',
            style: TextStyle(
              fontSize: CustomSize.appBarTitleSize,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            if (widget.source != 'setting')
              TextButton(
                onPressed: () {
                  context.go(Ability().homeRoute);
                },
                child: Text(
                  'Do not set',
                  style: TextStyle(
                    color: customColors.weakLinkColor,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.settings,
          enabled: false,
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MessageBox(
                    message: AppLocale.enableCustomOpenAI.getString(context),
                    type: MessageBoxType.info,
                  ),
                  const SizedBox(height: 10),
                  ColumnBlock(
                    children: [
                      if (widget.source == 'setting')
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocale.enable.getString(context),
                                style: TextStyle(
                                  color: customColors.textfieldLabelColor,
                                  fontSize: 16,
                                ),
                              ),
                              CupertinoSwitch(
                                activeColor: customColors.linkColor,
                                value: enableOpenAISelfHosted,
                                onChanged: (value) {
                                  setState(() {
                                    enableOpenAISelfHosted = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      EnhancedTextField(
                        customColors: customColors,
                        maxLength: 128,
                        labelText: 'Server URL',
                        labelWidth: 104,
                        labelPosition: LabelPosition.left,
                        controller: _urlController,
                        showCounter: false,
                        hintText: 'https://api.openai.com',
                      ),
                      EnhancedTextField(
                        customColors: customColors,
                        maxLength: 128,
                        labelText: 'API Key',
                        labelWidth: 104,
                        labelPosition: LabelPosition.left,
                        controller: _apiKeyController,
                        showCounter: false,
                        obscureText: true,
                        hintText: 'sk-xxxxxxx',
                      ),
                      EnhancedTextField(
                        customColors: customColors,
                        labelText: 'Organization ID',
                        labelFontSize: 14,
                        labelWidth: 104,
                        maxLength: 128,
                        labelPosition: LabelPosition.left,
                        controller: _organizationController,
                        showCounter: false,
                        hintText: AppLocale.optional.getString(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  EnhancedButton(
                    title: widget.source == 'setting' ? AppLocale.save.getString(context) : 'Enable',
                    onPressed: () {
                      var url = _urlController.text;
                      var apiKey = _apiKeyController.text;
                      var organization = _organizationController.text;

                      if (url == '') {
                        url = 'https://api.openai.com';
                      }

                      if (!url.startsWith('http://') && !url.startsWith('https://')) {
                        showErrorMessageEnhanced(context, 'The URL must begin with http:// or https://.');
                        return;
                      }

                      if (!enableOpenAISelfHosted) {
                        onSaveAndEnter(apiKey, organization, url, context);
                        return;
                      }

                      if (enableOpenAISelfHosted && apiKey == '') {
                        showErrorMessageEnhanced(context, 'API Key cannot be empty');
                        return;
                      }

                      verifySecretKey().then((value) {
                        onSaveAndEnter(apiKey, organization, url, context);
                      }).onError((error, stackTrace) {
                        showErrorMessage(error.toString());
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSaveAndEnter(String apiKey, String organization, String url, BuildContext context) async {
    await widget.settings.set(settingOpenAIAPIToken, apiKey);
    await widget.settings.set(settingOpenAIOrganization, organization);
    await widget.settings.set(settingOpenAIURL, url);

    if (widget.source == 'setting') {
      await widget.settings.set(
        settingOpenAISelfHosted,
        enableOpenAISelfHosted ? 'true' : 'false',
      );
      // ignore: use_build_context_synchronously
      showSuccessMessage(AppLocale.operateSuccess.getString(context));
    } else {
      await widget.settings.set(settingOpenAISelfHosted, 'true');
      if (context.mounted) {
        context.go(Ability().homeRoute);
      }
    }
  }

  Future<void> verifySecretKey() async {
    var url = _urlController.text;
    var apiKey = _apiKeyController.text;
    var organization = _organizationController.text;

    if (url == '') {
      url = 'https://api.openai.com';
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return Future.error('The URL must begin with http:// or https://.');
    }

    if (apiKey == '') {
      return Future.error('API Key cannot be empty');
    }

    final headers = <String, dynamic>{
      'Authorization': 'Bearer $apiKey',
    };

    if (organization != '') {
      headers['OpenAI-Organization'] = organization;
    }

    final cancelLoading = BotToast.showCustomLoading(
      toastBuilder: (cancel) {
        return LoadingIndicator(
          message: AppLocale.processingWait.getString(context),
        );
      },
      allowClick: false,
      duration: const Duration(seconds: 120),
    );

    final dio = Dio(BaseOptions(
      baseUrl: url,
      connectTimeout: const Duration(seconds: 5),
    ));

    try {
      final resp = await dio.get(
        '/v1/models',
        options: Options(
          headers: headers,
          receiveDataWhenStatusError: true,
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      if (resp.statusCode != 200) {
        cancelLoading();
        setState(() {
          verifySuccess = false;
        });
        return Future.error('Verification failed, please check the API Key: ${resp.data}');
      }

      cancelLoading();
      setState(() {
        verifySuccess = true;
      });
    } catch (e) {
      setState(() {
        verifySuccess = false;
      });

      cancelLoading();
      if (e is DioException) {
        if (e.response != null && e.response!.data != null) {
          return Future.error(
              'Verification failed, please check the network or API Key: ${e.response!.data["error"]["message"]}');
        } else {
          return Future.error('Verification failed, please check the network or API Key: ${e.error}');
        }
      } else {
        return Future.error('Verification failed, please check the network or API Key: ${e.toString()}');
      }
    }
  }
}
