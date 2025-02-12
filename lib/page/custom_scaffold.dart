import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatefulWidget {
  final SettingRepository settings;
  final Widget title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? drawer;
  final Widget? appBarBackground;
  final AppBar? backAppBar;
  final bool showBackAppBar;

  const CustomScaffold({
    super.key,
    required this.settings,
    required this.title,
    this.actions,
    required this.body,
    this.drawer,
    this.appBarBackground,
    this.backAppBar,
    this.showBackAppBar = false,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.settings,
        maxWidth: CustomSize.maxWindowSize,
        child: widget.body,
      ),
      drawer: widget.drawer,
    );
  }

  AppBar? buildAppBar() {
    if (widget.showBackAppBar && widget.backAppBar != null) {
      return widget.backAppBar;
    }

    return AppBar(
      title: widget.title,
      centerTitle: true,
      toolbarHeight: CustomSize.toolbarHeight,
      elevation: 0,
      actions: widget.actions,
      flexibleSpace: SizedBox(
        width: double.infinity,
        child: ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: widget.appBarBackground,
        ),
      ),
      leading: widget.drawer != null
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
    );
  }
}
