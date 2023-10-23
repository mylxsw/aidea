import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat_chat.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/data/chat_history_datasource.dart';
import 'package:askaide/page/theme/custom_size.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/chat_message_repo.dart';
import 'package:askaide/repo/model/chat_history.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';

class ChatHistoryPage extends StatefulWidget {
  final SettingRepository setting;
  final ChatMessageRepository chatMessageRepo;

  const ChatHistoryPage(
      {super.key, required this.setting, required this.chatMessageRepo});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late final ChatHistoryDatasource datasource;

  @override
  void initState() {
    datasource = ChatHistoryDatasource(widget.chatMessageRepo);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.histories.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        toolbarHeight: CustomSize.toolbarHeight,
        centerTitle: true,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: RefreshIndicator(
          color: customColors.linkColor,
          onRefresh: () async {
            await datasource.refresh();
          },
          child: BlocListener<ChatChatBloc, ChatChatState>(
            listenWhen: (previous, current) =>
                current is ChatChatRecentHistoriesLoaded,
            listener: (context, state) {
              if (state is ChatChatRecentHistoriesLoaded) {
                datasource.refresh();
              }
            },
            child: RefreshIndicator(
              color: customColors.linkColor,
              displacement: 20,
              onRefresh: () {
                return datasource.refresh();
              },
              child: LoadingMoreList(
                ListConfig<ChatHistory>(
                  itemBuilder: (context, item, index) {
                    return ChatHistoryItem(
                      history: item,
                      customColors: customColors,
                      onTap: () {
                        context
                            .push(
                                '/chat-anywhere?chat_id=${item.id}&model=${item.model}')
                            .whenComplete(() {
                          FocusScope.of(context).requestFocus(FocusNode());
                          context
                              .read<ChatChatBloc>()
                              .add(ChatChatLoadRecentHistories());
                        });
                      },
                    );
                  },
                  sourceList: datasource,
                  indicatorBuilder: (context, status) {
                    String msg = '';
                    switch (status) {
                      case IndicatorStatus.noMoreLoad:
                        msg = '~ 没有更多了 ~';
                        break;
                      case IndicatorStatus.loadingMoreBusying:
                        msg = '加载中...';
                        break;
                      case IndicatorStatus.error:
                        msg = '加载失败，请稍后再试';
                        break;
                      case IndicatorStatus.empty:
                        msg = '暂无数据';
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
        ),
      ),
    );
  }
}
