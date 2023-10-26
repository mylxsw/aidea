import 'dart:ui';

import 'package:askaide/helper/constant.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';

class BackgroundContainer extends StatefulWidget {
  final Widget child;
  final bool? useGradient;
  final SettingRepository setting;
  final bool enabled;
  final bool pureColorMode;
  final double maxWidth;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.useGradient,
    required this.setting,
    this.enabled = true,
    this.pureColorMode = false,
    this.maxWidth = CustomSize.maxWindowSize,
  });

  @override
  State<BackgroundContainer> createState() => _BackgroundContainerState();
}

class _BackgroundContainerState extends State<BackgroundContainer> {
  final int opacity = 180;
  String? imageUrl;
  double? blur;

  @override
  void initState() {
    super.initState();

    if (widget.enabled) {
      if ((widget.useGradient == null || widget.useGradient == false) &&
          imageUrl == null) {
        imageUrl = widget.setting.get(settingBackgroundImage);
        blur = double.tryParse(
          widget.setting.get(settingBackgroundImageBlur) ?? '15.0',
        );
      }

      widget.setting.listen((settings, key, value) {
        if (key == settingBackgroundImage) {
          if (mounted) {
            setState(() {
              imageUrl = value;
            });
          }
        }

        if (key == settingBackgroundImageBlur) {
          if (mounted) {
            setState(() {
              blur = double.tryParse(value);
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onHorizontalDragUpdate: (details) {
        int sensitivity = 10;
        if (details.delta.dx > sensitivity) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth > 0 ? widget.maxWidth : double.infinity,
          ),
          child: _buildChild(customColors),
        ),
      ),
    );
  }

  Widget _buildChild(CustomColors customColors) {
    if (widget.pureColorMode) {
      return Container(
        height: double.infinity,
        decoration: _createPureColorDecoration(customColors),
        child: widget.child,
      );
    }

    if (!widget.enabled) {
      return Container(
        height: double.infinity,
        decoration: _createTransportDecoration(),
        child: widget.child,
      );
    }

    if (widget.enabled &&
        ((imageUrl != null && imageUrl != '') || widget.useGradient == true)) {
      return Container(
        height: double.infinity,
        decoration: widget.useGradient == true
            ? _createLinearGradientDecoration()
            : BoxDecoration(
                image: _resolveImage(),
              ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur ?? 15.0,
            sigmaY: blur ?? 15.0,
          ),
          child: widget.child,
        ),
      );
    }

    return Container(
      decoration: _createPureColorDecoration(customColors),
      height: double.infinity,
      child: widget.child,
    );
  }

  DecorationImage _resolveImage() {
    return DecorationImage(
      image: resolveImageProvider(imageUrl!),
      fit: BoxFit.cover,
    );
  }

  BoxDecoration _createPureColorDecoration(CustomColors customColors) {
    return BoxDecoration(
      color: customColors.backgroundContainerColor,
    );
  }

  BoxDecoration _createLinearGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(opacity, 90, 218, 196),
            Color.fromARGB(opacity, 230, 153, 38),
            Color.fromARGB(opacity, 242, 7, 213),
          ],
          transform: const GradientRotation(0.5)),
    );
  }

  BoxDecoration _createTransportDecoration() {
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }
}
