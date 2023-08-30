import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/enhanced_error.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/page/creative_island/box.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

enum CreativeIslandMode {
  /// 创作岛
  creativeIsland,

  /// 绘图
  imageDraw;

  String getString() {
    switch (this) {
      case CreativeIslandMode.creativeIsland:
        return 'creative-island';
      case CreativeIslandMode.imageDraw:
        return 'image-draw';
    }
  }
}

/// 创作岛
class CreativeIsland extends StatefulWidget {
  final SettingRepository setting;
  const CreativeIsland({super.key, required this.setting});

  @override
  State<CreativeIsland> createState() => _CreativeIslandState();
}

class _CreativeIslandState extends State<CreativeIsland> {
  String? selectedCategory;
  AnimatedButtonController controller = AnimatedButtonController();

  @override
  void initState() {
    if (Ability().supportAPIServer()) {
      context.read<CreativeIslandBloc>().add(CreativeIslandListLoadEvent(
          mode: CreativeIslandMode.creativeIsland.getString()));
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Ability().supportAPIServer()
            ? _buildIslandItems(customColors)
            : Center(
                child: WeakTextButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  title: AppLocale.creativeIslandNeedSignIn.getString(context),
                  icon: Icons.account_circle,
                ),
              ),
      ),
    );
  }

  /// 创作岛列表
  Widget _buildIslandItems(
    CustomColors customColors,
  ) {
    return BlocBuilder<CreativeIslandBloc, CreativeIslandState>(
      buildWhen: (previous, current) => current is CreativeIslandListLoaded,
      builder: (context, state) {
        if (state is CreativeIslandListLoaded) {
          if (state.error != null) {
            return EnhancedErrorWidget(error: state.error);
          }

          return SliverTabComponent(
            tabBarTitles: state.categories,
            title: AnimatedTextKit(
              isRepeatingAnimation: false,
              animatedTexts: [
                TypewriterAnimatedText(
                  AppLocale.creativeIsland.getString(context),
                  textStyle:
                      const TextStyle(fontSize: CustomSize.appBarTitleSize),
                  speed: const Duration(milliseconds: 150),
                ),
              ],
            ),
            crossAxisCount: _calCrossAxisCount(context),
            itemsBuilder: (context, tabName) {
              return state.items
                  .where((e) => e.categories.contains(tabName))
                  .map((e) => CreativeIslandBox(item: e))
                  .toList();
            },
            backgroundImageUrl: state.backgroundImage,
            childAspectRatio: 1,
            actions: [
              IconButton(
                onPressed: () {
                  context.push(
                      '/creative-island/history?mode=${CreativeIslandMode.creativeIsland.getString()}');
                },
                icon: const Icon(Icons.list),
              ),
            ],
          );
        }

        return Center(
          child: CircularProgressIndicator(
            color: customColors.chatInputPanelText,
          ),
        );
      },
    );
  }

  int _calCrossAxisCount(BuildContext context) {
    return (MediaQuery.of(context).size.width / 200).round();
  }
}
