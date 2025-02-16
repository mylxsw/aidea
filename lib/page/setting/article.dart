import 'package:askaide/helper/ability.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/article.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ArticleScreen extends StatefulWidget {
  final SettingRepository settings;
  final int id;
  const ArticleScreen({super.key, required this.settings, required this.id});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  Article article = Article(
    id: 0,
    title: 'Title',
    content: 'Content',
  );

  @override
  void initState() {
    APIServer().article(id: widget.id).then((value) {
      setState(() {
        article = value;
      });
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
          title: Text(
            article.title,
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          toolbarHeight: CustomSize.toolbarHeight,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: customColors.weakLinkColor,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Ability().homeRoute);
              }
            },
          ),
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.settings,
          enabled: false,
          backgroundColor: customColors.backgroundColor,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: ColumnBlock(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Author: ${article.author ?? 'Admin'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: customColors.weakTextColor,
                              ),
                            ),
                            if (article.createdAt != null)
                              Text(
                                DateFormat('yyyy/MM/dd HH:mm').format(article.createdAt!.toLocal()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: customColors.weakTextColor?.withAlpha(100),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Markdown(
                          data: article.content,
                          onUrlTap: (value) {
                            if (value.startsWith("aidea-app://")) {
                              var route = value.substring('aidea-app://'.length);
                              context.push(route);
                            } else {
                              launchUrlString(value);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
