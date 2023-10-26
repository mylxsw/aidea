import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/image_preview.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class CreativeIslandGalleryScreen extends StatefulWidget {
  final SettingRepository setting;

  const CreativeIslandGalleryScreen({super.key, required this.setting});

  @override
  State<CreativeIslandGalleryScreen> createState() =>
      _CreativeIslandGalleryScreenState();
}

class _CreativeIslandGalleryScreenState
    extends State<CreativeIslandGalleryScreen> {
  @override
  void initState() {
    context
        .read<CreativeIslandBloc>()
        .add(CreativeIslandGalleryLoadEvent(mode: "all"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '创作岛 Gallery',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
      ),
      backgroundColor: customColors.chatInputPanelBackground,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: RefreshIndicator(
          color: customColors.linkColor,
          onRefresh: () async {
            context
                .read<CreativeIslandBloc>()
                .add(CreativeIslandGalleryLoadEvent(
                  forceRefresh: true,
                  mode: "all",
                ));
          },
          child: BlocConsumer<CreativeIslandBloc, CreativeIslandState>(
            listenWhen: (previous, current) =>
                current is CreativeIslandGalleryLoaded,
            buildWhen: (previous, current) =>
                current is CreativeIslandGalleryLoaded,
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
                  crossAxisCount: _calCrossAxisCount(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: state.items.where((e) => e.images.isNotEmpty).map(
                    (e) {
                      if (e.userId != null && e.userId! > 0) {
                        return GestureDetector(
                          onTap: () {
                            context.push(
                                '/creative-island/${e.islandId}/history/${e.id}');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImageEnhanced(
                                imageUrl: e.firstImagePreview,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetworkImagePreviewer(
                          url: e.firstImagePreview,
                          hidePreviewButton: true,
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
    );
  }

  int _calCrossAxisCount() {
    if (SizerUtil.deviceType == DeviceType.tablet) {
      if (SizerUtil.orientation == Orientation.landscape) {
        return 6;
      }
      return 4;
    }

    if (SizerUtil.orientation == Orientation.landscape) {
      return 6;
    }
    return 3;
  }
}
