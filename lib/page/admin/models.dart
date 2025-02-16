import 'package:askaide/bloc/model_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
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

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Large Language Model',
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
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
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
                    listenWhen: (previous, current) => current is ModelOperationResult,
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
                                e.name.toLowerCase().contains(keyword.toLowerCase()) ||
                                e.modelId.toLowerCase().contains(keyword.toLowerCase()) ||
                                (e.description ?? '').toLowerCase().contains(keyword.toLowerCase()))
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
                  () => context.read<ModelBloc>().add(ModelDeleteEvent(mod.modelId)),
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
            borderRadius: CustomSize.borderRadiusAll,
            onTap: () {
              context.push('/admin/models/edit/${Uri.encodeComponent(mod.modelId)}').then((value) {
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
                              borderRadius: const BorderRadius.only(bottomLeft: CustomSize.radius),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                width: 80,
                                color: Colors.black.withAlpha(30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      AppLocale.visionTag.getString(context),
                                      style: const TextStyle(
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
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontWeight: mod.enabled ? FontWeight.bold : FontWeight.normal,
                                color: mod.enabled ? null : customColors.weakLinkColor?.withAlpha(100),
                                decoration: mod.enabled ? null : TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 5),
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
                          mod.providers.map((e) => searchChannel(e).display).join('|'),
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
          borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
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
      borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
    );
  }

  String buildModelDescription(AdminModel mod) {
    String desc = '';
    if (mod.inputPrice > 0 || mod.outputPrice > 0 || mod.perReqPrice > 0) {
      desc += '💰 ';
      if (mod.inputPrice > 0 || mod.outputPrice > 0) {
        if (mod.inputPrice == mod.outputPrice) {
          desc += 'IO${AppLocale.creditUnit.getString(context)}${mod.inputPrice} ';
        } else {
          desc +=
              'I${AppLocale.creditUnit.getString(context)}${mod.inputPrice} O${AppLocale.creditUnit.getString(context)}${mod.outputPrice} ';
        }
      }

      if (mod.perReqPrice > 0) {
        desc += 'R${AppLocale.creditUnit.getString(context)}${mod.perReqPrice}';
      }
    }

    if (mod.maxContext > 0) {
      if (desc.isNotEmpty) {
        desc += '，';
      }

      desc += '🎞️ ${mod.maxContext} Tokens';
    }

    if (mod.meta != null && mod.meta!.tag != null && mod.meta!.tag != '') {
      desc += ' | ${mod.meta!.tag}';
    }

    if (desc != '') {
      desc += '\n';
    }

    return desc + (mod.description ?? '');
  }
}
