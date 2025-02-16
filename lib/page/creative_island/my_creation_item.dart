import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/creative_island/draw/components/content_preview.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';

class MyCreationItemPage extends StatefulWidget {
  final String islandId;
  final int itemId;
  final SettingRepository setting;
  final bool showErrorMessage;

  const MyCreationItemPage({
    super.key,
    required this.setting,
    required this.islandId,
    required this.itemId,
    required this.showErrorMessage,
  });

  @override
  State<MyCreationItemPage> createState() => _MyCreationItemPageState();
}

class _MyCreationItemPageState extends State<MyCreationItemPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.animateTo(1);

    context.read<CreativeIslandBloc>().add(CreativeIslandHistoryItemLoadEvent(widget.itemId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: BlocBuilder<CreativeIslandBloc, CreativeIslandState>(
        buildWhen: (previous, current) =>
            current is CreativeIslandHistoryItemLoaded || current is CreativeIslandHistoryItemLoading,
        builder: (context, state) {
          if (state is CreativeIslandHistoryItemLoaded) {
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: CustomSize.toolbarHeight,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  state.item!.showBetaFeature ? '#${state.item!.id}' : '',
                  style: TextStyle(
                    color: customColors.weakTextColor,
                  ),
                ),
                actions: buildActions(state, context, customColors),
              ),
              backgroundColor: customColors.backgroundColor,
              body: BackgroundContainer(
                setting: widget.setting,
                enabled: false,
                backgroundColor: customColors.backgroundColor,
                maxWidth: CustomSize.smallWindowSize,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: state.item!.isSuccessful
                              ? CreativeIslandContentPreview(
                                  result: IslandResult(
                                    result: state.item!.images,
                                    params: state.item!.params,
                                  ),
                                  customColors: customColors,
                                  item: state.item,
                                )
                              : _buildNotSuccessBox(state, customColors),
                        ),
                        ColumnBlock(
                          innerPanding: 10,
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          children: [
                            if (state.item!.prompt != null && state.item!.prompt != '')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocale.ideaPrompt.getString(context),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: customColors.textfieldLabelColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    state.item!.prompt ?? '',
                                    style: TextStyle(
                                      color: customColors.weakTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            if (state.item!.arguments != null)
                              ..._buildItemArguments(
                                state.item!.creativeItemArguments,
                                customColors,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<Widget> buildActions(
    CreativeIslandHistoryItemLoaded state,
    BuildContext context,
    CustomColors customColors,
  ) {
    if (state.item!.userId != APIServer().localUserID() && state.item!.isSuccessful) {
      return [
        TextButton(
          onPressed: () {
            openConfirmDialog(context, 'Are you sure to ban this project?', () {
              APIServer().forbidCreativeHistoryItem(historyId: state.item!.id).then((value) {
                showSuccessMessage(AppLocale.operateSuccess.getString(context));

                context.read<CreativeIslandBloc>().add(CreativeIslandHistoryItemLoadEvent(
                      widget.itemId,
                      forceRefresh: true,
                    ));
              });
            });
          },
          child: Row(
            children: [
              const Icon(
                Icons.block,
                color: Colors.amber,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                'Ban',
                style: TextStyle(
                  color: customColors.weakLinkColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      if (state.item!.isSuccessful && state.item!.showBetaFeature)
        TextButton(
          onPressed: () {
            if (state.item!.isShared) {
              APIServer().cancelShareCreativeHistoryToGallery(historyId: state.item!.id).then((value) {
                showSuccessMessage(AppLocale.operateSuccess.getString(context));

                context.read<CreativeIslandBloc>().add(CreativeIslandHistoryItemLoadEvent(
                      widget.itemId,
                      forceRefresh: true,
                    ));
              });
            } else {
              APIServer().shareCreativeHistoryToGallery(historyId: state.item!.id).then((value) {
                showSuccessMessage(AppLocale.operateSuccess.getString(context));

                context.read<CreativeIslandBloc>().add(CreativeIslandHistoryItemLoadEvent(
                      widget.itemId,
                      forceRefresh: true,
                    ));
              });
            }
          },
          child: Text(
            state.item!.isShared ? 'Set Private' : 'Set Public',
            style: TextStyle(
              color: customColors.weakLinkColor,
              fontSize: 12,
            ),
          ),
        )
    ];
  }

  Widget _buildNotSuccessBox(
    CreativeIslandHistoryItemLoaded state,
    CustomColors customColors,
  ) {
    if (state.item != null && state.item!.isFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocale.generateFailed.getString(context),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SelectableText(
              widget.showErrorMessage ? '${state.item!.answer}' : 'Error Code：${state.item!.errorCode}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: customColors.weakTextColor,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 50,
            color: customColors.weakTextColor,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocale.generate.getString(context),
            style: TextStyle(
              color: customColors.backgroundInvertedColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemArguments(CreativeItemArguments arg, CustomColors customColors) {
    final children = <Widget>[];

    if (arg.negativePrompt != null && arg.negativePrompt != '') {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.excludeContents.getString(context),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: customColors.textfieldLabelColor,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              arg.negativePrompt!,
              style: TextStyle(
                color: customColors.weakTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // if (arg.modelName != null && arg.modelName != '') {
    //   children.add(
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           'AI 模型',
    //           style: TextStyle(
    //             fontSize: 15,
    //             fontWeight: FontWeight.bold,
    //             color: customColors.textfieldLabelColor,
    //           ),
    //         ),
    //         const SizedBox(height: 10),
    //         SelectableText(
    //           arg.modelName!,
    //           style: TextStyle(
    //             color: customColors.weakTextColor,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    if (arg.filterName != null && arg.filterName != '') {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.style.getString(context),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: customColors.textfieldLabelColor,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              arg.filterName!,
              style: TextStyle(
                color: customColors.weakTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // if (arg.seed != null && arg.seed! > 0) {
    //   children.add(
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           'Seed',
    //           style: TextStyle(
    //             fontSize: 15,
    //             fontWeight: FontWeight.bold,
    //             color: customColors.textfieldLabelColor,
    //           ),
    //         ),
    //         const SizedBox(height: 10),
    //         SelectableText(
    //           '${arg.seed!}',
    //           style: TextStyle(
    //             color: customColors.weakTextColor,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // if (arg.image != null && arg.image != '') {
    //   children.add(
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           '原图',
    //           style: TextStyle(
    //             fontSize: 15,
    //             fontWeight: FontWeight.bold,
    //             color: customColors.textfieldLabelColor,
    //           ),
    //         ),
    //         const SizedBox(height: 10),
    //         NetworkImagePreviewer(url: arg.image!, hidePreviewButton: true),
    //       ],
    //     ),
    //   );
    // }

    return children;
  }
}
