import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/creative_island/creative_island.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/creative_island_repo.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class CreativeIslandHistoryPage extends StatefulWidget {
  final String id;
  final CreativeIslandRepository repo;
  final SettingRepository setting;
  const CreativeIslandHistoryPage({
    super.key,
    required this.id,
    required this.repo,
    required this.setting,
  });

  @override
  State<CreativeIslandHistoryPage> createState() =>
      _CreativeIslandHistoryPageState();
}

class _CreativeIslandHistoryPageState extends State<CreativeIslandHistoryPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<CreativeIslandBloc>()
        .add(CreativeIslandHistoriesLoadEvent(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BlocConsumer<CreativeIslandBloc, CreativeIslandState>(
      listener: (context, state) {
        if (state is CreativeIslandHistoriesLoaded) {
          if (state.error != null) {
            showErrorMessage(state.error);
          }
        }
      },
      listenWhen: (previous, current) {
        return current is CreativeIslandHistoriesLoaded;
      },
      buildWhen: (previous, current) {
        return current is CreativeIslandHistoriesLoaded;
      },
      builder: (context, state) {
        if (state is CreativeIslandHistoriesLoaded) {
          return Scaffold(
            appBar: _buildAppBar(context, state, customColors),
            // backgroundColor: customColors.chatInputPanelBackground,
            backgroundColor: customColors.backgroundContainerColor,
            body: BackgroundContainer(
              setting: widget.setting,
              enabled: false,
              child: RefreshIndicator(
                color: customColors.linkColor,
                onRefresh: () async {
                  context
                      .read<CreativeIslandBloc>()
                      .add(CreativeIslandHistoriesLoadEvent(
                        widget.id,
                        forceRefresh: true,
                      ));
                },
                child: state.histories.isNotEmpty
                    ? _buildHistoryItems(state, customColors)
                    : Center(
                        child: Text(AppLocale.noRecords.getString(context))),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context, null, customColors),
          backgroundColor: customColors.chatInputPanelBackground,
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  /// 构建历史项目列表
  Widget _buildHistoryItems(
    CreativeIslandHistoriesLoaded state,
    CustomColors customColors,
  ) {
    return ListView.builder(
      itemCount: state.histories.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(top: index == 0 ? 15 : 10),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  const SizedBox(width: 10),
                  SlidableAction(
                    label: AppLocale.delete.getString(context),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    onPressed: (_) {
                      openConfirmDialog(
                          context, AppLocale.confirmDelete.getString(context),
                          () {
                        context
                            .read<CreativeIslandBloc>()
                            .add(CreativeIslandDeleteEvent(
                              widget.id,
                              state.histories[index].id,
                              mode: (state.island.modelType ==
                                          creativeIslandModelTypeImage ||
                                      state.island.modelType ==
                                          creativeIslandModelTypeImageToImage)
                                  ? CreativeIslandMode.imageDraw.getString()
                                  : CreativeIslandMode.creativeIsland
                                      .getString(),
                            ));
                      });
                    },
                  ),
                ],
              ),
              child: Material(
                // color: customColors.chatExampleItemBackground,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                // color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _openHistoryItemDialog(context, state, index, customColors);
                  },
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    leading: _buildAnswerImagePreview(
                        context, state.histories[index]),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (state.histories[index].isTextType ||
                                !state.histories[index].isSuccessful)
                              _buildPrefixIcon(state.histories[index]),
                            if (state.histories[index].isTextType ||
                                !state.histories[index].isSuccessful)
                              const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.histories[index].prompt!
                                    .replaceAll('\n', ' '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              humanTime(state.histories[index].createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildAnswerTextPreview(
                            context, state.histories[index]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildAnswerImagePreview(
    BuildContext context,
    CreativeItemInServer item,
  ) {
    if (item.isImageType && item.images.isNotEmpty) {
      return SizedBox(
        height: 50,
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImageEnhanced(
            imageUrl: item.firstImagePreview,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildAnswerTextPreview(
    BuildContext context,
    CreativeItemInServer item,
  ) {
    if (item.isFailed) {
      return Text(
        '创作失败',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    if (item.isProcessing) {
      return Text(
        '创作中',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    if (item.isImageType && item.images.isNotEmpty) {
      return const SizedBox();
    }

    return Text(
      (item.answer ?? '').replaceAll('\n', ' '),
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 打开历史项目详情对话框
  _openHistoryItemDialog(
    BuildContext context,
    CreativeIslandHistoriesLoaded state,
    int index,
    CustomColors customColors,
  ) {
    context.push(
        '/creative-island/${widget.id}/history/${state.histories[index].id}');
  }

  AppBar _buildAppBar(
    BuildContext context,
    CreativeIslandHistoriesLoaded? state,
    CustomColors customColors,
  ) {
    return AppBar(
      title: Text(
        AppLocale.histories.getString(context),
        style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
      ),
      centerTitle: true,
      flexibleSpace: state != null
          ? SizedBox(
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
                child: Image(
                  image: CachedNetworkImageProviderEnhanced(
                    state.island.bgImage!,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPrefixIcon(CreativeItemInServer his) {
    if (his.isFailed) {
      return const Icon(
        Icons.error_outline,
        size: 18,
        color: Colors.red,
      );
    }

    if (his.isSuccessful) {
      return const Icon(Icons.tag, size: 18, color: Colors.green);
    }

    if (his.isProcessing) {
      return const Icon(
        Icons.hourglass_top,
        size: 18,
        color: Colors.blue,
      );
    }

    return const SizedBox();
  }
}
