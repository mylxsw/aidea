import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum LabelPosition { top, left, inner }

class InputSelector extends StatelessWidget {
  final Widget title;
  final VoidCallback onTap;

  const InputSelector({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: title,
    );
  }
}

class EnhancedTextField extends StatefulWidget {
  final int? maxLength;
  final bool? autofocus;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextAlignVertical? textAlignVertical;
  final CustomColors customColors;
  final String? labelText;
  final double? labelFontSize;
  final double? labelWidth;
  final Widget? labelWidget;
  final int? minLines;
  final int? maxLines;
  final bool showCounter;
  final String? hintText;
  final Widget? suffixIcon;
  final bool? readOnly;
  final bool? obscureText;
  final LabelPosition? labelPosition;
  final Widget? inputSelector;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final double? fieldWidth;
  final void Function(String)? onChanged;
  final String? initValue;
  final bool enableBackground;
  final Widget? bottomButtons;
  final Widget? bottomButton;
  final VoidCallback? bottomButtonOnPressed;
  final double? fontSize;
  final bool? enabled;

  final Color? hintColor;
  final double? hintTextSize;
  final Widget? labelHelpWidget;

  final Widget? middleWidget;

  const EnhancedTextField({
    super.key,
    required this.customColors,
    this.maxLength,
    this.autofocus,
    this.labelWidget,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.textAlignVertical,
    this.labelText,
    this.labelFontSize,
    this.labelWidth,
    this.minLines,
    this.maxLines = 1,
    this.showCounter = true,
    this.hintText,
    this.suffixIcon,
    this.readOnly,
    this.obscureText,
    this.labelPosition,
    this.inputSelector,
    this.inputFormatters,
    this.textDirection,
    this.fieldWidth,
    this.onChanged,
    this.initValue,
    this.bottomButtons,
    this.bottomButton,
    this.bottomButtonOnPressed,
    this.enableBackground = false,
    this.fontSize,
    this.enabled,
    this.hintColor,
    this.hintTextSize,
    this.labelHelpWidget,
    this.middleWidget,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  var textLength = 0;

  late final Function() listener;

  @override
  void initState() {
    super.initState();

    listener = () {
      if (mounted) {
        setState(() {
          textLength = widget.controller!.text.length;
        });
      }
    };

    if (widget.showCounter) {
      widget.controller?.addListener(listener);
    }
  }

  @override
  void dispose() {
    if (widget.showCounter) {
      widget.controller?.removeListener(listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.labelText != null || widget.labelWidget != null) &&
        widget.labelPosition != LabelPosition.inner) {
      // 上下结构
      if (widget.labelPosition == LabelPosition.top) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.labelWidget != null
                    ? widget.labelWidget!
                    : Row(
                        children: [
                          Text(
                            widget.labelText!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: widget.labelFontSize ?? 16,
                              color: widget.customColors.textfieldLabelColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (widget.labelHelpWidget != null)
                            widget.labelHelpWidget!,
                        ],
                      ),
                if (widget.inputSelector != null) widget.inputSelector!,
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(),
          ],
        );
      }

      // 左右结构
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: widget.labelWidth ?? 80,
            child: widget.labelWidget != null
                ? widget.labelWidget!
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          widget.labelText!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.labelFontSize ?? 16,
                            color: widget.customColors.textfieldLabelColor,
                          ),
                        ),
                      ),
                      if (widget.labelHelpWidget != null) ...[
                        const SizedBox(width: 5),
                        widget.labelHelpWidget!,
                      ]
                    ],
                  ),
          ),
          const SizedBox(width: 10),
          widget.fieldWidth != null
              ? SizedBox(
                  width: widget.fieldWidth,
                  child: _buildTextField(),
                )
              : Expanded(
                  child: _buildTextField(),
                ),
        ],
      );
    }

    // 无标题结构
    return _buildTextField();
  }

  Widget _buildTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: widget.initValue,
                  readOnly: widget.readOnly ?? false,
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  inputFormatters: widget.inputFormatters,
                  textDirection: widget.textDirection,
                  obscureText: widget.obscureText ?? false,
                  enabled: widget.enabled ?? true,
                  style: TextStyle(
                    color: widget.customColors.textfieldValueColor,
                    fontSize: widget.fontSize ?? 15,
                  ),
                  decoration: InputDecoration(
                    filled: widget.enableBackground,
                    fillColor: widget.customColors.textfieldBackgroundColor,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize:
                          widget.hintTextSize ?? CustomSize.defaultHintTextSize,
                      color: widget.hintColor ??
                          widget.customColors.textfieldHintColor,
                    ),
                    hintTextDirection: widget.textDirection,
                    counterText: "",
                    border: resolveInputBorder(),
                    enabledBorder: resolveInputBorder(),
                    focusedBorder: resolveInputBorder(),
                    // isDense: true,
                    contentPadding: EdgeInsets.only(
                      top: widget.labelPosition == LabelPosition.top ? 0 : 10,
                      left: widget.enableBackground ? 15 : 0,
                      right: widget.enableBackground ? 15 : 0,
                      bottom:
                          (widget.showCounter || widget.bottomButton != null) &&
                                  widget.middleWidget == null
                              ? 30
                              : 10,
                    ),
                    labelText: widget.labelPosition == LabelPosition.inner
                        ? widget.labelText
                        : null,
                    labelStyle: TextStyle(
                      color: widget.customColors.textfieldLabelColor,
                    ),
                    suffixIcon: widget.suffixIcon ??
                        (widget.labelPosition == LabelPosition.left
                            ? widget.inputSelector
                            : null),
                  ),
                  cursorRadius: const Radius.circular(10),
                  keyboardType: widget.keyboardType,
                  autofocus: widget.autofocus ?? false,
                  maxLength: widget.maxLength,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  onChanged: widget.controller == null
                      ? (value) {
                          setState(() {
                            textLength = value.length;
                          });

                          if (widget.onChanged != null) {
                            widget.onChanged!(value);
                          }
                        }
                      : null,
                ),
                widget.middleWidget ?? const SizedBox(),
              ],
            ),
            if (widget.showCounter)
              Positioned(
                right: 10,
                bottom: 10,
                child: Text(
                  "$textLength / ${widget.maxLength}",
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.customColors.chatInputPanelText,
                  ),
                ),
              ),
            if (widget.bottomButtons != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: widget.bottomButtons!,
              ),
            if (widget.bottomButton != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: MaterialButton(
                  elevation: 0,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  minWidth: 60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: widget.bottomButtonOnPressed,
                  child: widget.bottomButton!,
                ),
              ),
          ],
        ),
      ],
    );
  }

  InputBorder resolveInputBorder() {
    if (widget.enableBackground) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      );
    }

    return InputBorder.none;
  }
}
