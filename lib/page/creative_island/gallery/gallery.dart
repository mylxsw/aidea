import 'package:askaide/helper/ability.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/gallery/components/image_card.dart';
import 'package:askaide/page/creative_island/gallery/data/gallery_datasource.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';

class GalleryScreen extends StatefulWidget {
  final SettingRepository setting;
  const GalleryScreen({super.key, required this.setting});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GalleryDatasource datasource = GalleryDatasource();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    datasource.dispose();
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
        AppLocale.discover.getString(context),
        style: TextStyle(
          fontSize: CustomSize.appBarTitleSize,
          color: customColors.backgroundInvertedColor,
        ),
      ),
      actions: [
        if (Ability().enableCreationIsland)
          IconButton(
            onPressed: () {
              context.push('/creative-draw');
            },
            icon: const Icon(Icons.palette_outlined),
          ),
      ],
      child: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        backgroundColor: customColors.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            //   child: Text('热门作品'),
            // ),
            Expanded(
              child: RefreshIndicator(
                color: customColors.linkColor,
                displacement: 20,
                onRefresh: () {
                  return datasource.refresh();
                },
                child: LoadingMoreList(
                  ListConfig<CreativeGallery>(
                    itemBuilder: (context, item, index) {
                      return ImageCard(
                        images: [item.preview],
                        username: item.username,
                        userId: item.userId,
                        hotValue: item.hotValue,
                        onTap: () => context.push('/creative-draw/gallery/${item.id}'),
                      );
                    },
                    sourceList: datasource,
                    padding: const EdgeInsets.all(10),
                    extendedListDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calCrossAxisCount(context),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    indicatorBuilder: (context, status) {
                      String msg = '';
                      switch (status) {
                        case IndicatorStatus.noMoreLoad:
                          msg = '~ 没有更多了 ~';
                          break;
                        case IndicatorStatus.loadingMoreBusying:
                          msg = '加载中...';
                          break;
                        case IndicatorStatus.error:
                          msg = '加载失败，请稍后再试';
                          break;
                        case IndicatorStatus.empty:
                          msg = '暂无数据';
                          break;
                        default:
                          return const Center(child: LoadingIndicator());
                      }
                      return Container(
                        padding: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: Text(
                          msg,
                          style: TextStyle(
                            color: customColors.weakTextColor,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > CustomSize.maxWindowSize) {
      width = CustomSize.maxWindowSize;
    }
    return (width / 220).round();
  }
}
