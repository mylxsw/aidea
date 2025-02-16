import 'package:askaide/bloc/admin_room_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/pagination.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminRecentlyMessagesPage extends StatefulWidget {
  final SettingRepository setting;

  const AdminRecentlyMessagesPage({super.key, required this.setting});

  @override
  State<AdminRecentlyMessagesPage> createState() => _AdminRecentlyMessagesPageState();
}

class _AdminRecentlyMessagesPageState extends State<AdminRecentlyMessagesPage> {
  /// 当前页码
  int page = 1;

  /// 每页数量
  int perPage = 20;

  /// 搜索关键字
  final TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    context.read<AdminRoomBloc>().add(AdminRecentlyMessagesLoadEvent(
          perPage: perPage,
          page: page,
          keyword: keywordController.text,
        ));
    super.initState();
  }

  @override
  void dispose() {
    keywordController.dispose();
    super.dispose();
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
            'Chat History',
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
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: TextField(
                  controller: keywordController,
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
                  onEditingComplete: () {
                    context.read<AdminRoomBloc>().add(AdminRecentlyMessagesLoadEvent(
                          perPage: perPage,
                          page: page,
                          keyword: keywordController.text,
                        ));
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: customColors.linkColor,
                  onRefresh: () async {
                    context.read<AdminRoomBloc>().add(AdminRecentlyMessagesLoadEvent(
                          perPage: perPage,
                          page: page,
                          keyword: keywordController.text,
                        ));
                  },
                  displacement: 20,
                  child: BlocConsumer<AdminRoomBloc, AdminRoomState>(
                    listener: (context, state) {
                      if (state is AdminRoomOperationResult) {
                        if (state.success) {
                          showSuccessMessage(AppLocale.operateSuccess.getString(context));
                        } else {
                          showErrorMessage(AppLocale.operateFailed.getString(context));
                        }
                      }

                      if (state is AdminRecentlyMessagesLoaded) {
                        setState(() {
                          page = state.messages.page;
                          perPage = state.messages.perPage;
                        });
                      }
                    },
                    buildWhen: (previous, current) => current is AdminRecentlyMessagesLoaded,
                    builder: (context, state) {
                      if (state is AdminRecentlyMessagesLoaded) {
                        return SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: state.messages.data.length,
                                  itemBuilder: (context, index) {
                                    final message = state.messages.data[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
                                      child: Slidable(
                                        startActionPane: ActionPane(motion: const ScrollMotion(), children: [
                                          SlidableAction(
                                            label: AppLocale.character.getString(context),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: CustomSize.radius,
                                              bottomLeft: CustomSize.radius,
                                              topRight: CustomSize.radius,
                                              bottomRight: CustomSize.radius,
                                            ),
                                            backgroundColor: Colors.blue,
                                            icon: Icons.people,
                                            foregroundColor: Colors.white,
                                            onPressed: (_) {
                                              context.push('/admin/users/${message.userId}/rooms');
                                            },
                                          ),
                                        ]),
                                        endActionPane: ActionPane(
                                          motion: const ScrollMotion(),
                                          children: [
                                            const SizedBox(width: 10),
                                            SlidableAction(
                                              label: 'User',
                                              borderRadius: const BorderRadius.only(
                                                topLeft: CustomSize.radius,
                                                bottomLeft: CustomSize.radius,
                                                topRight: CustomSize.radius,
                                                bottomRight: CustomSize.radius,
                                              ),
                                              backgroundColor: customColors.linkColor ?? Colors.green,
                                              icon: Icons.person,
                                              foregroundColor: Colors.white,
                                              onPressed: (_) {
                                                context.push('/admin/users/${message.userId}');
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
                                              context.push(
                                                  '/admin/users/${message.userId}/rooms/${message.roomId}/messages?room_type=1');
                                            },
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: customColors.columnBlockBackgroundColor?.withAlpha(100),
                                                      borderRadius: const BorderRadius.only(
                                                        topRight: CustomSize.radius,
                                                        bottomLeft: CustomSize.radius,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '@ ${message.userId}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: customColors.weakTextColor?.withAlpha(100),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(15),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        state.messages.data[index].text,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '${message.model}',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                          if (message.ts != null)
                                                            Text(
                                                              '  ${DateFormat('MM/dd HH:mm').format(message.ts!.toLocal())}',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (state.messages.lastPage != null && state.messages.lastPage! > 1)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Pagination(
                                    numOfPages: state.messages.lastPage ?? 1,
                                    selectedPage: page,
                                    pagesVisible: 5,
                                    onPageChanged: (selected) {
                                      context.read<AdminRoomBloc>().add(AdminRecentlyMessagesLoadEvent(
                                            perPage: perPage,
                                            page: selected,
                                            keyword: keywordController.text,
                                          ));
                                    },
                                  ),
                                ),
                            ],
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
}
