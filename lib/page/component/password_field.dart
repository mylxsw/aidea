import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final String? labelText;
  final String? hintText;
  final bool inColumnBlock;

  const PasswordField({
    super.key,
    this.onSubmitted,
    this.controller,
    this.labelText,
    this.hintText,
    this.inColumnBlock = false,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var obscureText = true;

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      padding: widget.inColumnBlock ? const EdgeInsets.all(5) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.inColumnBlock)
            SizedBox(
              width: 80,
              child: Text(
                widget.labelText!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: customColors.textfieldLabelColor,
                ),
              ),
            ),
          if (widget.inColumnBlock) const SizedBox(width: 10),
          Expanded(
            child: TextField(
              obscureText: obscureText,
              inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: widget.inColumnBlock
                    ? InputBorder.none
                    : const OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(200, 192, 192, 192)),
                      ),
                focusedBorder: widget.inColumnBlock
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderSide: BorderSide(color: customColors.linkColor!),
                      ),
                // floatingLabelStyle: TextStyle(color: customColors.linkColor!),
                isDense: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: widget.inColumnBlock ? null : widget.labelText,
                labelStyle: const TextStyle(fontSize: 17),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: customColors.textfieldHintColor,
                  fontSize: 15,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 15,
                    color: const Color.fromARGB(150, 141, 141, 141),
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.visiblePassword,
              onSubmitted: widget.onSubmitted,
              controller: widget.controller,
            ),
          ),
        ],
      ),
    );
  }
}
