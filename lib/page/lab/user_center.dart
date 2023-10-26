import 'package:askaide/bloc/account_bloc.dart';
import 'package:askaide/bloc/creative_island_bloc.dart';
import 'package:askaide/page/component/account_quota_card.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/invite_card.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserCenterScreen extends StatefulWidget {
  final SettingRepository settings;
  const UserCenterScreen({super.key, required this.settings});

  @override
  State<UserCenterScreen> createState() => _UserCenterScreenState();
}

class _UserCenterScreenState extends State<UserCenterScreen> {
  @override
  void initState() {
    context.read<AccountBloc>().add(AccountLoadEvent());
    context
        .read<CreativeIslandBloc>()
        .add(CreativeIslandGalleryLoadEvent(mode: "default"));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.settings,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '我的信息',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<AccountBloc, AccountState>(
            buildWhen: (previous, current) => current is AccountLoaded,
            builder: (_, state) {
              if (state is AccountLoaded) {
                return BlocConsumer<CreativeIslandBloc, CreativeIslandState>(
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
                    builder: (context, state2) {
                      if (state2 is CreativeIslandGalleryLoaded) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AccountQuotaCard(
                                userInfo: state.user!,
                                onPaymentReturn: () {
                                  context
                                      .read<AccountBloc>()
                                      .add(AccountLoadEvent(cache: false));
                                },
                              ),
                              InviteCard(userInfo: state.user!),
                              GridView.count(
                                padding: const EdgeInsets.all(15),
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                cacheExtent: 100,
                                children: state2.items
                                    .where((e) => e.images.isNotEmpty)
                                    .map(
                                  (e) {
                                    return GestureDetector(
                                      onTap: () {
                                        context.push(
                                            '/creative-island/${e.islandId}/history/${e.id}');
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImageEnhanced(
                                          imageUrl: e.firstImagePreview,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    });
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
