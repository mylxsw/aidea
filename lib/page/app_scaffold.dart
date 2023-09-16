import 'package:askaide/helper/event.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/theme/custom_theme.dart';
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

  @override
  void initState() {
    GlobalEvent().on("hideBottomNavigatorBar", (data) {
      if (mounted) {
        setState(() {
          _showBottomNavigatorBar = false;
        });
      }
    });

    GlobalEvent().on("showBottomNavigatorBar", (data) {
      if (mounted) {
        setState(() {
          _showBottomNavigatorBar = true;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final customColors = Theme.of(context).extension<CustomColors>()!;
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
                createAnimatedNavBarItem(
                  icon: Icons.question_answer_outlined,
                  activatedIcon: Icons.question_answer,
                  activatedColor: customColors.linkColor,
                  label: AppLocale.chatAnywhere.getString(context),
                  activated: currentIndex == 0,
                ),
                createAnimatedNavBarItem(
                  icon: Icons.group_outlined,
                  activatedIcon: Icons.group,
                  activatedColor: customColors.linkColor,
                  label: AppLocale.homeTitle.getString(context),
                  activated: currentIndex == 1,
                ),
                createAnimatedNavBarItem(
                  icon: Icons.auto_awesome_outlined,
                  activatedIcon: Icons.auto_awesome,
                  activatedColor: customColors.linkColor,
                  label: AppLocale.discover.getString(context),
                  activated: currentIndex == 2,
                ),
                createAnimatedNavBarItem(
                  icon: Icons.palette_outlined,
                  activatedIcon: Icons.palette,
                  activatedColor: customColors.linkColor,
                  label: AppLocale.creativeIsland.getString(context),
                  activated: currentIndex == 3,
                ),
                createAnimatedNavBarItem(
                  icon: Icons.manage_accounts_outlined,
                  activatedIcon: Icons.manage_accounts,
                  activatedColor: customColors.linkColor,
                  label: AppLocale.me.getString(context),
                  activated: currentIndex == 4,
                ),
              ],
            )
          : null,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.location.split('?').first;

    if (location == '/chat-chat') return 0;
    if (location == '/') return 1;
    if (location == '/creative-gallery') return 2;
    if (location == '/creative-draw') return 3;
    if (location == '/setting') return 4;

    return -1;
  }

  void onTap(int value) {
    HapticFeedbackHelper.lightImpact();
    switch (value) {
      case 0:
        return context.go('/chat-chat');
      case 1:
        return context.go('/');
      case 2:
        return context.go('/creative-gallery');
      case 3:
        return context.go('/creative-draw');
      case 4:
        return context.go('/setting');
      default:
        return context.go('/');
    }
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
