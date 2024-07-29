import 'package:askaide/bloc/model_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/admin/channels.dart';
import 'package:askaide/repo/api/admin/models.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class AdminModelsPage extends StatefulWidget {
  final SettingRepository setting;
  const AdminModelsPage({
    super.key,
    required this.setting,
  });

  @override
  State<AdminModelsPage> createState() => _AdminModelsPageState();
}

class _AdminModelsPageState extends State<AdminModelsPage> {
  // 渠道
  List<AdminChannel> channels = [];

  // 搜索关键字
  String keyword = '';

  /// 查找渠道
  AdminChannel searchChannel(AdminModelProvider provider) {
    return channels.firstWhere(
      (e) {
        if (e.id == null && (provider.id == null || provider.id == 0)) {
          return provider.name == e.type;
        }

        return provider.id == e.id;
      },
      orElse: () {
        return AdminChannel(
          id: provider.id,
          name: '未知',
          type: 'unknown',
        );
      },
    );
  }

  @override
  void initState() {
    // 加载渠道
    APIServer().adminChannelsAgg().then((value) {
      if (context.mounted) {
        setState(() {
          channels = value;
        });

        // 加载模型列表
        context.read<ModelBloc>().add(ModelsLoadEvent());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: const Text(
          '大语言模型管理',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/admin/models/create').then((value) {
                context.read<ModelBloc>().add(ModelsLoadEvent());
              });
            },
          ),
        ],
      ),
      backgroundColor: customColors.chatInputPanelBackground,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: customColors.dialogDefaultTextColor),
                decoration: InputDecoration(
                  hintText: AppLocale.search.getString(context),
                  hintStyle: TextStyle(
                    color: customColors.dialogDefaultTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: customColors.dialogDefaultTextColor,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => keyword = value),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: customColors.linkColor,
                onRefresh: () async {
                  context.read<ModelBloc>().add(ModelsLoadEvent());
                },
                displacement: 20,
                child: BlocConsumer<ModelBloc, ModelState>(
                  listenWhen: (previous, current) =>
                      current is ModelOperationResult,
                  listener: (context, state) {
                    if (state is ModelOperationResult) {
                      if (state.success) {
                        showSuccessMessage(state.message);
                        context.read<ModelBloc>().add(ModelsLoadEvent());
                      } else {
                        showErrorMessage(state.message);
                      }
                    }
                  },
                  buildWhen: (previous, current) => current is ModelsLoaded,
                  builder: (context, state) {
                    if (state is ModelsLoaded) {
                      final models = state.models
                          .where((e) =>
                              keyword == '' ||
                              e.name
                                  .toLowerCase()
                                  .contains(keyword.toLowerCase()) ||
                              e.modelId
                                  .toLowerCase()
                                  .contains(keyword.toLowerCase()) ||
                              (e.description ?? '')
                                  .toLowerCase()
                                  .contains(keyword.toLowerCase()))
                          .toList();
                      return SafeArea(
                        top: false,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(5),
                          itemCount: models.length,
                          itemBuilder: (context, index) {
                            final mod = models[index];

                            return buildModelItem(context, customColors, mod);
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
          ],
        ),
      ),
    );
  }

  Widget buildModelItem(
    BuildContext context,
    CustomColors customColors,
    AdminModel mod,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(customColors.borderRadius ?? 8),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: AppLocale.delete.getString(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(customColors.borderRadius ?? 8),
                bottomLeft: Radius.circular(customColors.borderRadius ?? 8),
                topRight: Radius.circular(customColors.borderRadius ?? 8),
                bottomRight: Radius.circular(customColors.borderRadius ?? 8),
              ),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              onPressed: (_) {
                openConfirmDialog(
                  context,
                  AppLocale.confirmToDeleteRoom.getString(context),
                  () => context
                      .read<ModelBloc>()
                      .add(ModelDeleteEvent(mod.modelId)),
                  danger: true,
                );
              },
            ),
          ],
        ),
        child: Material(
          borderRadius:
              BorderRadius.all(Radius.circular(customColors.borderRadius ?? 8)),
          color: customColors.columnBlockBackgroundColor,
          child: InkWell(
            borderRadius: BorderRadius.all(
                Radius.circular(customColors.borderRadius ?? 8)),
            onTap: () {
              context
                  .push(
                      '/admin/models/edit/${Uri.encodeComponent(mod.modelId)}')
                  .then((value) {
                context.read<ModelBloc>().add(ModelsLoadEvent());
              });
            },
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 头像
                    Stack(
                      children: [
                        buildAvatar(mod),
                        if (mod.isVision)
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                width: 80,
                                color: Colors.black.withAlpha(30),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '视觉',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    // 名称
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mod.name,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              buildModelDescription(mod),
                              style: TextStyle(
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                color: customColors.weakTextColor,
                              ),
                              maxLines: 2,
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
                    width: MediaQuery.of(context).size.width / 2.0,
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mod.providers
                              .map((e) => searchChannel(e).display)
                              .join('|'),
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

  Widget buildAvatar(AdminModel mod) {
    if (mod.avatarUrl != null && mod.avatarUrl!.startsWith('http')) {
      return SizedBox(
        width: 80,
        height: 80,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          child: CachedNetworkImage(
            imageUrl: imageURL(mod.avatarUrl!, qiniuImageTypeAvatar),
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    return Initicon(
      text: mod.name.split('、').join(' '),
      size: 80,
      backgroundColor: Colors.grey.withAlpha(100),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
    );
  }

  String buildModelDescription(AdminModel mod) {
    String desc = '';
    if (mod.inputPrice > 0 || mod.outputPrice > 0) {
      desc += '💰 ';
      if (mod.inputPrice == mod.outputPrice) {
        desc += '${mod.inputPrice} 智慧果/1K Token';
      } else {
        desc += '${mod.inputPrice} / ${mod.outputPrice} 智慧果/1K Token';
      }
    }

    if (mod.maxContext > 0) {
      if (desc.isNotEmpty) {
        desc += '，';
      }

      desc += '🎞️ ${mod.maxContext} Tokens';
    }

    if (desc != '') {
      desc += '\n';
    }

    return desc + (mod.description ?? '');
  }
}
