import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/color.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/draw/components/creative_item.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class DrawListScreen extends StatefulWidget {
  final SettingRepository setting;
  const DrawListScreen({super.key, required this.setting});

  @override
  State<DrawListScreen> createState() => _DrawListScreenState();
}

class _DrawListScreenState extends State<DrawListScreen> {
  @override
  void initState() {
    if (Ability().isUserLogon()) {
      userSignedIn = true;
    }

    context.read<CreativeIslandBloc>().add(CreativeIslandItemsV2LoadEvent(forceRefresh: false));

    super.initState();
  }

  bool userSignedIn = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        backgroundColor: customColors.backgroundColor,
        body: _buildIslandItems(customColors),
      ),
    );
  }

  /// 创作岛列表
  Widget _buildIslandItems(
    CustomColors customColors,
  ) {
    return SliverComponent(
      title: Text(
        AppLocale.creativeIsland.getString(context),
        style: TextStyle(
          fontSize: CustomSize.appBarTitleSize,
          color: customColors.backgroundInvertedColor,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (userSignedIn) {
              context.push('/creative-island/history?mode=image-draw');
            } else {
              context.push('/login');
            }
          },
          icon: const Icon(Icons.crop_original),
        ),
      ],
      child: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        backgroundColor: customColors.backgroundColor,
        child: BlocBuilder<CreativeIslandBloc, CreativeIslandState>(
          buildWhen: (previous, current) => current is CreativeIslandItemsV2Loaded,
          builder: (context, state) {
            if (state is CreativeIslandItemsV2Loaded) {
              final items = state.items
                  .map((e) => CreativeItem(
                        imageURL: e.previewImage,
                        title: e.title,
                        titleColor: stringToColor(e.titleColor),
                        tag: e.tag,
                        onTap: () {
                          var uri = Uri.tryParse(e.routeUri);
                          if (e.note != null && e.note != '') {
                            uri = uri!.replace(
                                queryParameters: <String, String>{
                              'note': e.note!,
                            }..addAll(uri.queryParameters));
                          }

                          context.push(uri.toString());
                        },
                        size: e.size,
                      ))
                  .toList();
              final largeItems = items.where((e) => e.size == 'large').toList();
              final mediumItems = items.where((e) => e.size == 'medium').toList();
              final otherItems = items.where((e) => e.size != 'large' && e.size != 'medium').toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CreativeIslandBloc>().add(CreativeIslandItemsV2LoadEvent(forceRefresh: true));
                },
                color: customColors.linkColor,
                displacement: 20,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                        crossAxisCount: _calCrossAxisCount(context),
                        childAspectRatio: 2,
                        shrinkWrap: true,
                        children: largeItems
                            .map((e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  child: e,
                                ))
                            .toList(),
                      ),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                        crossAxisCount: _calCrossAxisCount(context) * 2,
                        childAspectRatio: 1,
                        shrinkWrap: true,
                        children: mediumItems
                            .map((e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  child: e,
                                ))
                            .toList(),
                      ),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                        crossAxisCount: _calCrossAxisCount(context) * 2,
                        childAspectRatio: 2,
                        shrinkWrap: true,
                        children: otherItems
                            .map((e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  child: e,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  int _calCrossAxisCount(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width > CustomSize.maxWindowSize) {
      width = CustomSize.maxWindowSize;
    }

    return (width / 400).round() > 2 ? 2 : (width / 400).round();
  }
}
