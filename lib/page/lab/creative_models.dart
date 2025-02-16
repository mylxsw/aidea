import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/image_model.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreativeModelScreen extends StatefulWidget {
  final SettingRepository setting;
  const CreativeModelScreen({super.key, required this.setting});

  @override
  State<CreativeModelScreen> createState() => _CreativeModelScreenState();
}

class _CreativeModelScreenState extends State<CreativeModelScreen> {
  List<ImageModel> imageModels = [];
  List<ImageModelFilter> imageModelFilters = [];

  @override
  void initState() {
    APIServer().imageModels().then((models) {
      setState(() {
        imageModels = models;
      });
    });

    APIServer().imageModelFilters().then((filters) {
      setState(() {
        imageModelFilters = filters;
      });
    });

    context.read<CreativeIslandBloc>().add(CreativeIslandGalleryLoadEvent(mode: "all"));
    super.initState();
  }

  ImageModel? selectedModel;
  ImageModelFilter? selectedFilter;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Creation Island History',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
          enabled: false,
          child: Column(
            children: [
              ColumnBlock(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                children: [
                  EnhancedInput(
                    title: Text(
                      AppLocale.model.getString(context),
                      style: TextStyle(
                        color: customColors.textfieldLabelColor,
                        fontSize: 16,
                      ),
                    ),
                    value: Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width - 200,
                      child: Text(
                        selectedModel?.modelName ?? 'Auto',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () {
                      openListSelectDialog(
                        context,
                        [
                          SelectorItem(const Text('Auto'), null),
                          ...imageModels
                              .map(
                                (e) => SelectorItem(
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(top: 25, bottom: 10),
                                        alignment: Alignment.center,
                                        child: Text(
                                          e.modelName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 14),
                                          textWidthBasis: TextWidthBasis.longestLine,
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: CustomSize.borderRadius,
                                            color: modelTypeTagColors[e.vendor],
                                          ),
                                          child: Text(
                                            e.vendor,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  e.id,
                                  search: (keywrod) {
                                    return e.modelName.toLowerCase().contains(keywrod.toLowerCase()) ||
                                        e.vendor.contains(keywrod.toLowerCase());
                                  },
                                ),
                              )
                              .toList(),
                        ],
                        (value) {
                          setState(() {
                            if (value.value == null) {
                              selectedModel = null;
                              selectedFilter = null;
                              context.read<CreativeIslandBloc>().add(CreativeIslandGalleryLoadEvent(mode: "all"));
                              return;
                            }

                            selectedModel = imageModels.firstWhere((e) => e.id == value.value);

                            if (selectedModel != null) {
                              final matchedFilters =
                                  imageModelFilters.where((e) => e.modelId == selectedModel!.modelId).toList();
                              selectedFilter = matchedFilters.isNotEmpty ? matchedFilters.first : null;
                              context
                                  .read<CreativeIslandBloc>()
                                  .add(CreativeIslandGalleryLoadEvent(mode: "all", model: selectedModel!.realModel));
                            } else {
                              selectedFilter = null;
                              context.read<CreativeIslandBloc>().add(CreativeIslandGalleryLoadEvent(mode: "all"));
                            }
                          });
                          return true;
                        },
                        heightFactor: 0.8,
                        value: selectedModel?.id,
                        innerPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        enableSearch: true,
                      );
                    },
                  ),
                  if (selectedFilter != null)
                    Row(
                      children: [
                        if (selectedFilter!.previewImage != null && selectedFilter!.previewImage!.isNotEmpty)
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: NetworkImagePreviewer(
                              url: selectedFilter!.previewImage!,
                              hidePreviewButton: true,
                            ),
                          ),
                        const SizedBox(width: 20),
                        Text(selectedFilter!.name),
                      ],
                    ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  color: customColors.linkColor,
                  onRefresh: () async {
                    context.read<CreativeIslandBloc>().add(CreativeIslandGalleryLoadEvent(
                          forceRefresh: true,
                          mode: "all",
                          model: selectedModel?.realModel,
                        ));
                  },
                  child: BlocConsumer<CreativeIslandBloc, CreativeIslandState>(
                    listenWhen: (previous, current) => current is CreativeIslandGalleryLoaded,
                    buildWhen: (previous, current) => current is CreativeIslandGalleryLoaded,
                    listener: (context, state) {
                      if (state is CreativeIslandHistoriesAllLoaded) {
                        if (state.error != null) {
                          showErrorMessageEnhanced(context, state.error);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is CreativeIslandGalleryLoaded) {
                        return GridView.count(
                          padding: const EdgeInsets.all(10),
                          crossAxisCount: _calCrossAxisCount(context),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: state.items.map(
                            (e) {
                              return GestureDetector(
                                onTap: () {
                                  context.push('/creative-island/${e.islandId}/history/${e.id}?show_error=true');
                                },
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
                                  child: Stack(
                                    children: [
                                      if (e.firstImagePreview.startsWith('http://') ||
                                          e.firstImagePreview.startsWith('https://'))
                                        ClipRRect(
                                          borderRadius: CustomSize.borderRadius,
                                          child: e.firstImagePreview.endsWith('.mp4')
                                              ? CachedNetworkImageEnhanced(
                                                  imageUrl: e.params['image'] ?? e.firstImagePreview,
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                )
                                              : CachedNetworkImageEnhanced(
                                                  imageUrl: e.firstImagePreview,
                                                  fit: BoxFit.cover,
                                                ),
                                        )
                                      else if (e.isProcessing)
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: CustomSize.borderRadius,
                                            color: const Color.fromARGB(255, 148, 124, 245),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Processing...',
                                              textAlign: TextAlign.center,
                                              maxLines: 4,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: CustomSize.borderRadius,
                                            color: Colors.amber,
                                          ),
                                          child: Center(
                                            child: Text(
                                              e.answer ?? '',
                                              textAlign: TextAlign.center,
                                              maxLines: 4,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        right: 10,
                                        bottom: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: customColors.backgroundColor?.withAlpha(200),
                                            borderRadius: CustomSize.borderRadius,
                                          ),
                                          child: Text(
                                            '${DateFormat('HH:mm').format(e.createdAt!.toLocal())}@${e.userId}#${e.id}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: customColors.weakTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (e.islandName != null)
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: CustomSize.radius,
                                                bottomRight: CustomSize.radius,
                                              ),
                                              color: customColors.linkColor,
                                            ),
                                            child: Text(
                                              e.islandName!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ],
          ),
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
