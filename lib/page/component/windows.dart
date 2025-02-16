import 'package:askaide/helper/platform.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowFrameWidget extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;

  const WindowFrameWidget({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    if (!PlatformTool.isDesktop()) {
      return child;
    }

    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowBorder(
      color: Colors.transparent,
      width: 0,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? customColors.backgroundContainerColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [Expanded(child: MoveWindow()), const WindowButtons()],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color.fromARGB(255, 93, 93, 93),
    mouseOver: const Color.fromARGB(255, 90, 90, 90),
    mouseDown: const Color.fromARGB(255, 171, 171, 171),
    iconMouseOver: const Color.fromARGB(255, 190, 190, 190),
    iconMouseDown: const Color.fromARGB(255, 217, 217, 217));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
