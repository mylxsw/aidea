import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/event.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatefulWidget {
  final SettingRepository settingRepo;
  const AppScaffold({
    Key? key,
    required this.child,
    required this.settingRepo,
  }) : super(key: key);
  final Widget child;
  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  var _showBottomNavigatorBar = true;

  Function? cancelHideBottomNavigatorBarEventListener;
  Function? cancelShowBottomNavigatorBarEventListener;

  @override
  void dispose() {
    cancelHideBottomNavigatorBarEventListener?.call();
    cancelShowBottomNavigatorBarEventListener?.call();

    super.dispose();
  }

  @override
  void initState() {
    cancelHideBottomNavigatorBarEventListener =
        GlobalEvent().on("hideBottomNavigatorBar", (data) {
      if (mounted) {
        setState(() {
          _showBottomNavigatorBar = false;
        });
      }
    });

    cancelShowBottomNavigatorBarEventListener =
        GlobalEvent().on("showBottomNavigatorBar", (data) {
      if (mounted) {
        setState(() {
          _showBottomNavigatorBar = true;
        });
      }
    });

    super.initState();
  }

  List<BottomNavigationBarConfig> _bottomNavigationBarList(
      {int? currentIndex}) {
    return [

      BottomNavigationBarConfig(
        builder: (index, customColors) => createAnimatedNavBarItem(
          icon: Icons.auto_awesome_outlined,
          activatedIcon: Icons.auto_awesome,
          activatedColor: customColors.linkColor,
          label: "AI换装",
          activated: currentIndex == index,
        ),
        route: '/change-outfits',
      ),
      if (Ability().enableChat)
        BottomNavigationBarConfig(
          builder: (index, customColors) => createAnimatedNavBarItem(
            icon: Icons.question_answer_outlined,
            activatedIcon: Icons.question_answer,
            activatedColor: customColors.linkColor,
            label: AppLocale.chatAnywhere.getString(context),
            activated: currentIndex == index,
          ),
          route: '/chat-chat',
        ),
      if (Ability().enableDigitalHuman)
        BottomNavigationBarConfig(
          builder: (index, customColors) => createAnimatedNavBarItem(
            icon: Icons.group_outlined,
            activatedIcon: Icons.group,
            activatedColor: customColors.linkColor,
            label: AppLocale.homeTitle.getString(context),
            activated: currentIndex == index,
          ),
          route: '/',
        ),


      if (Ability().enableGallery)
        BottomNavigationBarConfig(
          builder: (index, customColors) => createAnimatedNavBarItem(
            icon: Icons.auto_awesome_outlined,
            activatedIcon: Icons.auto_awesome,
            activatedColor: customColors.linkColor,
            label: AppLocale.discover.getString(context),
            activated: currentIndex == index,
          ),
          route: '/creative-gallery',
        ),
      if (Ability().enableCreationIsland)
        BottomNavigationBarConfig(
          builder: (index, customColors) => createAnimatedNavBarItem(
            icon: Icons.palette_outlined,
            activatedIcon: Icons.palette,
            activatedColor: customColors.linkColor,
            label: AppLocale.creativeIsland.getString(context),
            activated: currentIndex == index,
          ),
          route: '/creative-draw',
        ),
      BottomNavigationBarConfig(
        builder: (index, customColors) => createAnimatedNavBarItem(
          icon: Icons.manage_accounts_outlined,
          activatedIcon: Icons.manage_accounts,
          activatedColor: customColors.linkColor,
          label: AppLocale.me.getString(context),
          activated: currentIndex == index,
        ),
        route: '/setting',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final barItems = _bottomNavigationBarList(currentIndex: currentIndex);
    return Scaffold(
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.settingRepo,
        enabled: true,
        child: widget.child,
      ),
      extendBody: false,
      bottomNavigationBar: currentIndex > -1 && _showBottomNavigatorBar
          ? BottomNavigationBar(
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              currentIndex: _calculateSelectedIndex(context),
              onTap: onTap,
              selectedItemColor: customColors.linkColor,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              enableFeedback: true,
              backgroundColor: customColors.backgroundColor,
              elevation: 0,
              items: [
                for (var i = 0; i < barItems.length; i++)
                  barItems[i].builder(i, customColors),
              ],
            )
          : null,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.location.split('?').first;

    final barItems = _bottomNavigationBarList();
    for (var i = 0; i < barItems.length; i++) {
      if (barItems[i].route == location) return i;
    }

    return -1;
  }

  void onTap(int value) {
    if (context.canPop()) {
      context.pop();
    }

    HapticFeedbackHelper.lightImpact();

    final barItems = _bottomNavigationBarList();
    if (value >= barItems.length) return context.go(Ability().homeRoute);

    return context.go(barItems[value].route);
  }
}

BottomNavigationBarItem createAnimatedNavBarItem({
  String? label,
  bool activated = false,
  Color? activatedColor,
  required IconData icon,
  required IconData activatedIcon,
}) {
  return BottomNavigationBarItem(
    label: label,
    icon: AnimatedCrossFade(
      firstChild: Icon(icon),
      secondChild: Icon(activatedIcon, color: activatedColor ?? Colors.green),
      crossFadeState:
          activated ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    ),
  );
}

class BottomNavigationBarConfig {
  final BottomNavigationBarItem Function(int index, CustomColors customColors)
      builder;
  final String route;

  BottomNavigationBarConfig({
    required this.builder,
    required this.route,
  });
}
