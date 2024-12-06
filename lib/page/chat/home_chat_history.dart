import 'package:askaide/bloc/chat_chat_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/chat/home.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
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

    return Scaffold(
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
        child: SafeArea(
          top: false,
          left: false,
          right: false,
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
                          return ChatHistoryItem(
                            history: item,
                            customColors: customColors,
                            onTap: () {
                              context
                                  .push('/chat-anywhere?chat_id=${item.id}&model=${item.model}&title=${item.title}')
                                  .whenComplete(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                context.read<ChatChatBloc>().add(ChatChatLoadRecentHistories());
                              });
                            },
                          );
                        },
                        sourceList: datasource,
                        indicatorBuilder: (context, status) {
                          String msg = '';
                          switch (status) {
                            case IndicatorStatus.noMoreLoad:
                              msg = '~ No more left ~';
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
    );
  }
}
