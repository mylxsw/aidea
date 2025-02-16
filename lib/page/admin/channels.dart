import 'package:askaide/bloc/channel_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/admin/channels.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class ChannelsPage extends StatefulWidget {
  final SettingRepository setting;
  const ChannelsPage({
    super.key,
    required this.setting,
  });

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  // 渠道类型
  List<AdminChannelType> channelTypes = [];

  @override
  void initState() {
    context.read<ChannelBloc>().add(ChannelsLoadEvent());

    // 加载渠道类型
    APIServer().adminChannelTypes().then((value) {
      if (context.mounted) {
        setState(() {
          channelTypes = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Channel',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.push('/admin/channels/create').then((value) {
                  context.read<ChannelBloc>().add(ChannelsLoadEvent());
                });
              },
            ),
          ],
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: RefreshIndicator(
            color: customColors.linkColor,
            onRefresh: () async {
              context.read<ChannelBloc>().add(ChannelsLoadEvent());
            },
            displacement: 20,
            child: BlocConsumer<ChannelBloc, ChannelState>(
              listenWhen: (previous, current) => current is ChannelOperationResult,
              listener: (context, state) {
                if (state is ChannelOperationResult) {
                  if (state.success) {
                    showSuccessMessage(state.message);
                    context.read<ChannelBloc>().add(ChannelsLoadEvent());
                  } else {
                    showErrorMessage(state.message);
                  }
                }
              },
              buildWhen: (previous, current) => current is ChannelsLoaded,
              builder: (context, state) {
                if (state is ChannelsLoaded) {
                  return SafeArea(
                    top: false,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: state.channels.length,
                      itemBuilder: (context, index) {
                        final channel = state.channels[index];

                        return buildChannelItem(context, customColors, channel);
                      },
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChannelItem(
    BuildContext context,
    CustomColors customColors,
    AdminChannel channel,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: AppLocale.delete.getString(context),
              borderRadius: const BorderRadius.only(
                topLeft: CustomSize.radius,
                bottomLeft: CustomSize.radius,
                topRight: CustomSize.radius,
                bottomRight: CustomSize.radius,
              ),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              onPressed: (_) {
                openConfirmDialog(
                  context,
                  AppLocale.confirmToDeleteRoom.getString(context),
                  () => context.read<ChannelBloc>().add(ChannelDeleteEvent(channel.id!)),
                  danger: true,
                );
              },
            ),
          ],
        ),
        child: Material(
          borderRadius: CustomSize.borderRadius,
          color: customColors.columnBlockBackgroundColor,
          child: InkWell(
            borderRadius: const BorderRadius.all(CustomSize.radius),
            onTap: () {
              context.push('/admin/channels/edit/${channel.id}').then((value) {
                context.read<ChannelBloc>().add(ChannelsLoadEvent());
              });
            },
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 渠道头像
                    Initicon(
                      text: channel.name.split('、').join(' '),
                      size: 50,
                      backgroundColor: Colors.grey.withAlpha(100),
                      borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
                    ),
                    // 渠道名称
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              channel.name,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channelTypes.firstWhere((e) => e.name == channel.type).text,
                          style: TextStyle(
                            fontSize: 10,
                            overflow: TextOverflow.ellipsis,
                            color: customColors.weakTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
