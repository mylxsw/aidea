import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/creative_island/content_preview.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class CreativeIslandResultDialog extends StatefulWidget {
  final Future<IslandResult> future;
  final int waitDuration;

  const CreativeIslandResultDialog({
    super.key,
    required this.future,
    this.waitDuration = 30,
  });

  @override
  State<CreativeIslandResultDialog> createState() =>
      _CreativeIslandResultDialogState();
}

const defaultCounterRestartValue = 15;

class _CreativeIslandResultDialogState
    extends State<CreativeIslandResultDialog> {
  var loading = true;
  var restartCounterValue = defaultCounterRestartValue;

  CountDownController controller = CountDownController();

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: CustomSize.smallWindowSize),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocale.generateResult.getString(context),
              style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
            ),
            toolbarHeight: CustomSize.toolbarHeight,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (loading) {
                  openConfirmDialog(
                    context,
                    AppLocale.generateExitConfirm.getString(context),
                    () => Navigator.pop(context),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          backgroundColor: customColors.backgroundContainerColor,
          body: FutureBuilder(
            future: widget.future,
            builder: (context, snapshot) {
              if (snapshot.hasData || snapshot.hasError) {
                HapticFeedbackHelper.mediumImpact();
                loading = false;
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '创作失败',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          resolveError(context, snapshot.error!),
                          style: TextStyle(
                            color: customColors.weakTextColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasData) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CreativeIslandContentPreview(
                        result: snapshot.data!,
                        customColors: customColors,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              }

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountDownProgressBar(
                      duration: widget.waitDuration,
                      controller: controller,
                      onComplete: (controller) {
                        if (!loading) {
                          return;
                        }

                        if (restartCounterValue == defaultCounterRestartValue) {
                          showSuccessMessage('当前排队人数较多，还需要等待一下哦');
                        }

                        controller.restart(duration: restartCounterValue);
                        setState(() {
                          restartCounterValue += 1;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '正在打造神奇...',
                      style: TextStyle(
                        color: customColors.backgroundInvertedColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '如队列太长，将会有数分钟等待时间',
                      style: TextStyle(
                        color: customColors.backgroundInvertedColor
                            ?.withAlpha(150),
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CountDownProgressBar extends StatefulWidget {
  final int duration;
  final CountDownController controller;
  final Function(CountDownController controller)? onComplete;
  const CountDownProgressBar({
    super.key,
    required this.duration,
    required this.controller,
    this.onComplete,
  });

  @override
  State<CountDownProgressBar> createState() => _CountDownProgressBarState();
}

class _CountDownProgressBarState extends State<CountDownProgressBar> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return CircularCountDownTimer(
      controller: widget.controller,
      duration: widget.duration,
      initialDuration: 0,
      width: MediaQuery.of(context).size.width / 3,
      height: MediaQuery.of(context).size.height / 3,
      ringColor: Colors.grey[300]!,
      fillColor: customColors.linkColor!,
      strokeWidth: 10.0,
      strokeCap: StrokeCap.round,
      textStyle: const TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold),
      textFormat: CountdownTextFormat.S,
      isReverse: true,
      isReverseAnimation: true,
      isTimerTextShown: true,
      autoStart: true,
      onComplete: () {
        widget.onComplete?.call(widget.controller);
      },
    );
  }
}
