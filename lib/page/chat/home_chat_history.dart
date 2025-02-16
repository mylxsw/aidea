import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/home.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/page/data/chat_history_datasource.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';

class HomeChatHistoryPage extends StatefulWidget {
  final SettingRepository setting;
  final ChatMessageRepository chatMessageRepo;

  const HomeChatHistoryPage({super.key, required this.setting, required this.chatMessageRepo});

  @override
  State<HomeChatHistoryPage> createState() => _HomeChatHistoryPageState();
}

class _HomeChatHistoryPageState extends State<HomeChatHistoryPage> {
  late final ChatHistoryDatasource datasource;

  String? keyword;

  @override
  void initState() {
    datasource = ChatHistoryDatasource(widget.chatMessageRepo);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocale.histories.getString(context),
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          toolbarHeight: CustomSize.toolbarHeight,
          centerTitle: true,
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
                  decoration: BoxDecoration(
                    color: customColors.textfieldBackgroundColor,
                    borderRadius: CustomSize.borderRadius,
                  ),
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
                    onChanged: (value) {
                      setState(() {
                        keyword = value;
                      });

                      datasource.refresh(false, keyword);
                    },
                  ),
                ),
                Expanded(
                  child: BlocListener<ChatChatBloc, ChatChatState>(
                    listenWhen: (previous, current) => current is ChatChatRecentHistoriesLoaded,
                    listener: (context, state) {
                      if (state is ChatChatRecentHistoriesLoaded) {
                        datasource.refresh(false, keyword);
                      }
                    },
                    child: RefreshIndicator(
                      color: customColors.linkColor,
                      displacement: 20,
                      onRefresh: () {
                        return datasource.refresh(false, keyword);
                      },
                      child: LoadingMoreList(
                        ListConfig<ChatHistory>(
                          itemBuilder: (context, item, index) {
                            // Get previous item to check if we need a header
                            final prevItem = index > 0 ? datasource[index - 1] : null;

                            final now = DateTime.now();
                            final itemDate = DateTime.fromMillisecondsSinceEpoch(
                                (item.createdAt ?? DateTime.now()).millisecondsSinceEpoch);
                            final prevDate = prevItem != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    (prevItem.createdAt ?? DateTime.now()).millisecondsSinceEpoch)
                                : null;

                            // Helper function to get time group
                            String getTimeGroup(DateTime date) {
                              final difference = now.difference(date);

                              if (difference.inDays < 4) {
                                return AppLocale.recently.getString(context);
                              } else if (difference.inDays < 7) {
                                return '4 ${AppLocale.daysAgo.getString(context)}';
                              } else if (difference.inDays < 14) {
                                return AppLocale.lastWeek.getString(context);
                              } else if (difference.inDays < 30) {
                                final weeks = (difference.inDays / 7).floor();
                                return '$weeks ${AppLocale.weeksAgo.getString(context)}';
                              } else if (difference.inDays < 365) {
                                if (difference.inDays < 60) {
                                  return AppLocale.lastMonth.getString(context);
                                }
                                final months = (difference.inDays / 30).floor();
                                return '$months ${AppLocale.monthsAgo.getString(context)}';
                              } else if (difference.inDays < 730) {
                                return AppLocale.lastYear.getString(context);
                              } else {
                                return AppLocale.longTimeAgo.getString(context);
                              }
                            }

                            final currentGroup = getTimeGroup(itemDate);
                            final prevGroup = prevDate != null ? getTimeGroup(prevDate) : null;

                            // Show header if group changed
                            final showHeader = currentGroup.isNotEmpty && currentGroup != prevGroup;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5),
                                    child: Text(
                                      currentGroup,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: customColors.weakTextColor,
                                      ),
                                    ),
                                  ),
                                ChatHistoryItem(
                                  history: item,
                                  customColors: customColors,
                                  onTap: () {
                                    context
                                        .push(
                                            '/chat-anywhere?chat_id=${item.id}&model=${item.model}&title=${item.title}')
                                        .whenComplete(() {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                          sourceList: datasource,
                          indicatorBuilder: (context, status) {
                            String msg = '';
                            switch (status) {
                              case IndicatorStatus.noMoreLoad:
                                msg = '';
                                break;
                              case IndicatorStatus.loadingMoreBusying:
                                msg = 'Loading...';
                                break;
                              case IndicatorStatus.error:
                                msg = 'Failed to load, please try again later';
                                break;
                              case IndicatorStatus.empty:
                                msg = 'No data';
                                break;
                              default:
                                return const Center(child: LoadingIndicator());
                            }
                            return Container(
                              padding: const EdgeInsets.all(15),
                              alignment: Alignment.center,
                              child: Text(
                                msg,
                                style: TextStyle(
                                  color: customColors.weakTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
