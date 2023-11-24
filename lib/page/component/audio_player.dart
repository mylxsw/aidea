import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AudioPlayerController {
  List<String> audioSources = [];
  int currentAudioIndex = 0;

  late AudioPlayer player;
  late tts.FlutterTts flutterTts;

  Function()? onPlayStopped;
  Function()? onPlayAudioStarted;
  Function(bool loading)? onPlayAudioLoading;

  final bool useRemoteAPI;

  AudioPlayerController({required this.useRemoteAPI}) {
    if (useRemoteAPI) {
      player = AudioPlayer();
      player.onPlayerComplete.listen((event) {
        if (currentAudioIndex < audioSources.length) {
          playNextAudioForPlayer();
        } else {
          if (onPlayStopped != null) {
            onPlayStopped!();
          }
        }
      });
    } else {
      flutterTts = tts.FlutterTts();
      if (PlatformTool.isIOS()) {
        flutterTts.setSharedInstance(true);
        flutterTts.setIosAudioCategory(
          tts.IosTextToSpeechAudioCategory.playback,
          [
            tts.IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            tts.IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            tts.IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }

      flutterTts.setStartHandler(() {
        if (onPlayAudioStarted != null) {
          onPlayAudioStarted!();
        }
      });

      flutterTts.setErrorHandler((msg) {
        Logger.instance.e('TTS error: $msg');
      });

      flutterTts.setCancelHandler(() {
        if (onPlayStopped != null) {
          onPlayStopped!();
        }
      });

      flutterTts.completionHandler = () {
        if (onPlayStopped != null) {
          onPlayStopped!();
        }
      };
    }
  }

  void dispose() {
    if (useRemoteAPI) {
      player.dispose();
    } else {
      flutterTts.stop();
    }
  }

  Future<void> playAudio(String text) async {
    await stop();

    if (text.isEmpty) {
      return;
    }

    if (useRemoteAPI) {
      if (onPlayAudioStarted != null) {
        onPlayAudioStarted!();
      }
      onPlayAudioLoading?.call(true);
      resetAudioSourcesForPlayer(await APIServer().textToVoice(text: text));
      onPlayAudioLoading?.call(false);
      playNextAudioForPlayer();
    } else {
      flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    if (useRemoteAPI) {
      await player.stop();
      if (onPlayStopped != null) {
        onPlayStopped!();
      }
    } else {
      await flutterTts.stop();
    }
  }

  Future<void> playNextAudioForPlayer() async {
    if (audioSources.isEmpty) {
      return;
    }

    if (currentAudioIndex >= audioSources.length) {
      return;
    }

    await player.play(UrlSource(audioSources[currentAudioIndex]));
    currentAudioIndex++;
  }

  void resetAudioSourcesForPlayer(List<String> sources) {
    audioSources = sources;
    currentAudioIndex = 0;
  }
}

class EnhancedAudioPlayer extends StatelessWidget {
  final AudioPlayerController controller;
  final bool loading;
  const EnhancedAudioPlayer(
      {super.key, required this.controller, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 100),
        loading
            ? Row(
                children: [
                  Text(
                    '语音合成中，请稍候',
                    style: TextStyle(
                      color: customColors.weakTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  LoadingAnimationWidget.fourRotatingDots(
                    color: const Color.fromARGB(255, 254, 170, 74),
                    size: 12,
                  ),
                ],
              )
            : LoadingAnimationWidget.staggeredDotsWave(
                color: const Color.fromARGB(255, 254, 170, 74),
                size: 25,
              ),
        if (!loading)
          SizedBox(
            width: 100,
            child: TextButton.icon(
              onPressed: () {
                controller.stop();
              },
              icon: Icon(
                Icons.stop_circle_outlined,
                color: customColors.weakLinkColor,
              ),
              label: Text(
                '停止',
                style: TextStyle(
                  color: customColors.weakLinkColor,
                  fontSize: 12,
                ),
              ),
            ),
          )
        else
          const SizedBox(width: 100),
      ],
    );
  }
}
