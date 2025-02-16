import 'package:askaide/helper/ability.dart';
import 'package:askaide/helper/event.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/bloc/room_bloc.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_error.dart';
import 'package:askaide/page/component/global_alert.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/chat/component/character_box.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/room_gallery.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class CharactersPage extends StatefulWidget {
  final SettingRepository setting;
  const CharactersPage({Key? key, required this.setting}) : super(key: key);

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  @override
  void initState() {
    context.read<RoomBloc>().add(RoomsLoadEvent());

    super.initState();
  }

  List<RoomGallery> selectedSuggestions = [];

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocale.homeTitle.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          toolbarHeight: CustomSize.toolbarHeight,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                context.push('/create-room').whenComplete(() {
                  if (context.mounted) {
                    context.read<RoomBloc>().add(RoomsLoadEvent());
                  }
                });
              },
            ),
          ],
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
          enabled: false,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: BlocConsumer<RoomBloc, RoomState>(
              listener: (context, state) {
                if (state is RoomsLoaded) {
                  if (state.rooms.isNotEmpty) {
                    selectedSuggestions.clear();
                    setState(() {});
                    GlobalEvent().emit('showBottomNavigatorBar');
                  }
                }

                if (state is RoomCreateError) {
                  showErrorMessageEnhanced(context, state.error);
                }

                if (state is RoomOperationResult) {
                  if (!state.success) {
                    showErrorMessageEnhanced(context, state.error ?? AppLocale.operateFailed.getString(context));
                  } else {
                    if (state.redirect != null) {
                      context.push(state.redirect!);
                    }
                  }
                }
              },
              buildWhen: (previous, current) => current is RoomsLoading || current is RoomsLoaded,
              builder: (context, state) {
                if (state is RoomsLoaded) {
                  if (state.error != null) {
                    return EnhancedErrorWidget(error: state.error);
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: customColors.linkColor,
                          onRefresh: () async {
                            context.read<RoomBloc>().add(RoomsLoadEvent(forceRefresh: true));
                          },
                          displacement: 20,
                          child: Column(
                            children: [
                              if (Ability().showGlobalAlert) const GlobalAlert(pageKey: 'rooms'),
                              Expanded(child: buildBody(customColors, state, context)),
                            ],
                          ),
                        ),
                      ),
                      if (selectedSuggestions.isNotEmpty)
                        Container(
                          height: 70,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              WeakTextButton(
                                title: AppLocale.cancel.getString(context),
                                onPressed: () {
                                  selectedSuggestions.clear();
                                  setState(() {});
                                  GlobalEvent().emit('showBottomNavigatorBar');
                                },
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: EnhancedButton(
                                    title: AppLocale.ok.getString(context),
                                    onPressed: () {
                                      context
                                          .read<RoomBloc>()
                                          .add(GalleryRoomCopyEvent(selectedSuggestions.map((e) => e.id).toList()));
                                      showSuccessMessage(AppLocale.operateSuccess.getString(context));
                                    }),
                              )
                            ],
                          ),
                        ),
                    ],
                  );
                }

                return const Center(
                  child: LoadingIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColumnTitle(BuildContext context, CustomColors customColors, String title) {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Text(title, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget buildBody(CustomColors customColors, RoomsLoaded state, BuildContext context) {
    List<Widget> children = [];

    if (state.rooms.isNotEmpty) {
      children.addAll([
        buildColumnTitle(context, customColors, AppLocale.myCharacters.getString(context)),
        ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: state.rooms.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final room = state.rooms[index];

            return CharacterBox(room: room);
          },
        ),
      ]);
    }

    if (state.suggests.isNotEmpty) {
      children.addAll([
        const SizedBox(height: 10),
        buildColumnTitle(context, customColors, AppLocale.robotRecommand.getString(context)),
        ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: state.suggests.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
              child: CharacterBoxItem(
                onTap: () {
                  HapticFeedbackHelper.lightImpact();
                  context.read<RoomBloc>().add(GalleryRoomCopyEvent([state.suggests[index].id]));
                },
                name: state.suggests[index].name,
                desc: state.suggests[index].description,
                avatarUrl: state.suggests[index].avatarUrl,
              ),
            );
          },
        ),
      ]);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void onItemSelected(RoomGallery item) {
    if (selectedSuggestions.contains(item)) {
      selectedSuggestions.remove(item);
    } else {
      selectedSuggestions.add(item);
    }

    setState(() {});

    if (selectedSuggestions.isEmpty) {
      GlobalEvent().emit('showBottomNavigatorBar');
    } else {
      GlobalEvent().emit('hideBottomNavigatorBar');
    }
  }
}
