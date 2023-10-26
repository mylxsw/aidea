import 'dart:async';
import 'dart:io';

import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/model_resolver.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:record/record.dart';

class VoiceRecord extends StatefulWidget {
  final Function(String text) onFinished;
  final Function() onStart;
  const VoiceRecord(
      {super.key, required this.onFinished, required this.onStart});

  @override
  State<VoiceRecord> createState() => _VoiceRecordState();
}

class _VoiceRecordState extends State<VoiceRecord> {
  var _voiceRecording = false;
  final record = Record();
  DateTime? _voiceStartTime;
  Timer? _timer;
  var _millSeconds = 0;

  @override
  void initState() {
    super.initState();
    record.hasPermission().then((hasPermission) {
      if (!hasPermission) {
        showErrorMessage('请授予录音权限');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 90,
          child: _voiceRecording
              ? Column(
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color.fromARGB(255, 74, 74, 254),
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text('${(_millSeconds / 1000.0).toStringAsFixed(3)} s'),
                  ],
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onLongPressStart: (details) async {
            widget.onStart();

            if (await record.hasPermission()) {
              // 震动反馈
              HapticFeedbackHelper.heavyImpact();

              setState(() {
                _voiceRecording = true;
                _voiceStartTime = DateTime.now();
              });
              // Start recording
              await record.start(
                encoder: AudioEncoder.aacLc, // by default
                bitRate: 128000, // by default
                samplingRate: 44100, // by default
              );

              setState(() {
                _millSeconds = 0;
              });
              if (_timer != null) {
                _timer!.cancel();
                _timer = null;
              }

              _timer = Timer.periodic(const Duration(milliseconds: 100),
                  (timer) async {
                if (_voiceStartTime == null) {
                  timer.cancel();
                  return;
                }

                if (DateTime.now().difference(_voiceStartTime!).inSeconds >=
                    60) {
                  await onRecordStop();
                  return;
                }

                setState(() {
                  _millSeconds = DateTime.now()
                      .difference(_voiceStartTime!)
                      .inMilliseconds;
                });
              });
            }
          },
          onLongPressEnd: (details) async {
            if (!_voiceRecording) {
              return;
            }

            setState(() {
              _voiceRecording = false;
            });

            await onRecordStop();
          },
          child: SizedBox(
            height: 80,
            width: 80,
            child: CircleAvatar(
              backgroundColor: _voiceRecording
                  ? customColors.linkColor
                  : customColors.linkColor!.withAlpha(200),
              child: _voiceRecording
                  ? const Icon(Icons.mic, size: 50)
                  : const Icon(Icons.mic, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocale.longPressSpeak.getString(context),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future onRecordStop() async {
    _timer?.cancel();

    var resPath = await record.stop();
    if (resPath == null) {
      showErrorMessage('语音输入失败');
      return;
    }

    final voiceDuration = DateTime.now().difference(_voiceStartTime!).inSeconds;
    if (voiceDuration < 2) {
      showErrorMessage('说话时间太短');
      _voiceStartTime = null;
      File.fromUri(Uri.parse(resPath)).delete();
      return;
    }

    if (voiceDuration > 60) {
      showErrorMessage('说话时间太长');
      _voiceStartTime = null;
      File.fromUri(Uri.parse(resPath)).delete();
      return;
    }

    _voiceStartTime = null;

    final cancel = BotToast.showCustomLoading(
      toastBuilder: (cancel) {
        return LoadingIndicator(
          message: AppLocale.processingWait.getString(context),
        );
      },
      allowClick: false,
      duration: const Duration(seconds: 120),
    );

    try {
      final audioFile = File.fromUri(Uri.parse(resPath));
      widget.onFinished(await ModelResolver.instance.audioToText(audioFile));
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorMessageEnhanced(context, e);
    } finally {
      cancel();
      // 删除临时文件
      if (!resPath.startsWith('blob:')) {
        File.fromUri(Uri.parse(resPath)).delete();
      }
    }
  }
}
