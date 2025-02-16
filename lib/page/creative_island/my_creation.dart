import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/button.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/draw/data/draw_history_datasource.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';

class MyCreationScreen extends StatefulWidget {
  final SettingRepository setting;
  final String mode;
  const MyCreationScreen({super.key, required this.setting, required this.mode});

  @override
  State<MyCreationScreen> createState() => _MyCreationScreenState();
}

class _MyCreationScreenState extends State<MyCreationScreen> {
  final DrawHistoryDatasource datasource = DrawHistoryDatasource();

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
        appBar: AppBar(
          title: const Text(
            '我的创作',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          toolbarHeight: CustomSize.toolbarHeight,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          maxWidth: CustomSize.maxWindowSize,
          backgroundColor: customColors.backgroundColor,
          child: SafeArea(
            child: RefreshIndicator(
              color: customColors.linkColor,
              onRefresh: () async {
                context
                    .read<CreativeIslandBloc>()
                    .add(CreativeIslandHistoriesAllLoadEvent(forceRefresh: true, mode: widget.mode));
              },
              child: LoadingMoreList(
                ListConfig<CreativeItemInServer>(
                  extendedListDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calCrossAxisCount(context),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, item, index) {
                    return Material(
                      color: customColors.backgroundContainerColor,
                      borderRadius: CustomSize.borderRadius,
                      child: InkWell(
                        borderRadius: CustomSize.borderRadiusAll,
                        onTap: () {
                          context.push('/creative-island/${item.islandId}/history/${item.id}?show_error=true');
                        },
                        onLongPress: () {
                          openModalBottomSheet(
                            context,
                            (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(height: 20),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Button(
                                        title: '查看作品',
                                        onPressed: () {
                                          context.push(
                                              '/creative-island/${item.islandId}/history/${item.id}?show_error=true');
                                          context.pop();
                                        },
                                        size: const ButtonSize.full(),
                                        color: customColors.weakLinkColor,
                                        backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                                      ),
                                      const SizedBox(height: 10),
                                      Button(
                                        title: '删除作品',
                                        onPressed: () {
                                          onItemDelete(
                                            context,
                                            item,
                                            index,
                                            onFinished: () {
                                              context.pop();
                                            },
                                          );
                                        },
                                        size: const ButtonSize.full(),
                                        color: customColors.weakLinkColor,
                                        backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                                      ),
                                      const SizedBox(height: 10),
                                      Button(
                                        title: AppLocale.cancel.getString(context),
                                        backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                                        color: customColors.dialogDefaultTextColor?.withAlpha(150),
                                        onPressed: () {
                                          context.pop();
                                        },
                                        size: const ButtonSize.full(),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ],
                              );
                            },
                            heightFactor: 0.25,
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                _buildAnswerImagePreview(context, item),
                                // TODO 风格名称，测试阶段使用
                                if (item.filterName != null && item.filterName!.isNotEmpty)
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                            topRight: CustomSize.radius, bottomLeft: CustomSize.radius),
                                      ),
                                      child: Text(
                                        item.filterName!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (item.isShared)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                          topRight: CustomSize.radius,
                                          bottomLeft: CustomSize.radius,
                                        ),
                                      ),
                                      child: const Text(
                                        '公开',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  buildIslandTypeText(customColors, item),
                                  Text(
                                    humanTime(item.createdAt, withTime: true),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customColors.weakTextColor?.withAlpha(150),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  sourceList: datasource,
                  padding: const EdgeInsets.all(10),
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
                        msg = '您还没有创作过作品哦';
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
        ),
      ),
    );
  }

  Widget buildIslandTypeText(CustomColors customColors, CreativeItemInServer item) {
    return Text(
      item.islandTitle ?? '',
      style: TextStyle(
        color: customColors.weakTextColor?.withAlpha(150),
        fontSize: 12,
      ),
    );
  }

  void onItemDelete(BuildContext context, CreativeItemInServer item, int index, {Function? onFinished}) {
    openConfirmDialog(context, AppLocale.confirmDelete.getString(context), () {
      APIServer().deleteCreativeHistoryItem(item.islandId, hisId: item.id).then((value) {
        // datasource.refresh(true);
        datasource.removeAt(index);
        setState(() {});
        showSuccessMessage(AppLocale.operateSuccess.getString(context));
        onFinished?.call();
      });
    });
  }

  Widget _buildAnswerImagePreview(
    BuildContext context,
    CreativeItemInServer item,
  ) {
    if (item.isVideoType && item.originalImage != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
              child: CachedNetworkImageEnhanced(
                imageUrl: imageURL(item.originalImage!, qiniuImageTypeThumbMedium),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Image.asset(
                'assets/play.png',
                width: 40,
                opacity: const AlwaysStoppedAnimation(0.7),
              ),
            ),
          ],
        ),
      );
    } else if (item.isImageType && item.images.isNotEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
              child: CachedNetworkImageEnhanced(
                imageUrl: imageURL(item.images.first, qiniuImageTypeThumbMedium),
                fit: BoxFit.cover,
              ),
            ),
            if (item.params['image'] != null && item.params['image'] != '')
              Positioned(
                left: 8,
                bottom: 8,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: CustomSize.borderRadius,
                    child: CachedNetworkImageEnhanced(
                      imageUrl: imageURL(item.params['image'], qiniuImageTypeAvatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (item.isFailed) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 150,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
              SizedBox(height: 10),
              Text('创作失败', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 150,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_bottom,
              size: 40,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 10),
            Text('创作中', style: TextStyle(color: Colors.blue[700]))
          ],
        ),
      ),
    );
  }

  int _calCrossAxisCount(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width > CustomSize.maxWindowSize) {
      width = CustomSize.maxWindowSize;
    }

    return (width / 220).round();
  }
}
