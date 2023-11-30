import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class SliverSingleComponent extends StatelessWidget {
  final Widget? title;
  final Widget? backgroundImage;
  final List<Widget>? actions;
  final double expendedHeight;
  final List<Widget> Function() appBarExtraWidgets;
  final EdgeInsets? titlePadding;
  final bool centerTitle;

  const SliverSingleComponent({
    super.key,
    required this.title,
    this.backgroundImage,
    this.actions,
    this.expendedHeight = 80,
    required this.appBarExtraWidgets,
    this.titlePadding,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: expendedHeight,
          floating: false,
          pinned: true,
          snap: false,
          primary: true,
          actions: (actions ?? []).isEmpty
              ? null
              : <Widget>[...actions!, const SizedBox(width: 8)],
          backgroundColor: customColors.backgroundContainerColor,
          flexibleSpace: FlexibleSpaceBar(
            title: title,
            centerTitle: centerTitle,
            titlePadding: titlePadding,
            background: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: backgroundImage,
            ),
            expandedTitleScale: 1.1,
          ),
        ),
        ...appBarExtraWidgets(),
      ],
    );
  }
}

class SliverComponent extends StatelessWidget {
  final Widget? title;
  final Widget? backgroundImage;
  final List<Widget>? actions;
  final double expendedHeight;
  final Widget child;
  final List<Widget> Function(bool innerBoxIsScrolled)? appBarExtraWidgets;
  final EdgeInsets? titlePadding;
  final bool centerTitle;
  const SliverComponent({
    super.key,
    required this.title,
    this.backgroundImage,
    this.actions,
    this.expendedHeight = 80,
    required this.child,
    this.appBarExtraWidgets,
    this.titlePadding,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: CustomSize.toolbarHeight,
            expandedHeight: expendedHeight,
            floating: false,
            pinned: true,
            snap: false,
            primary: true,
            actions: (actions ?? []).isEmpty
                ? null
                : <Widget>[...actions!, const SizedBox(width: 8)],
            backgroundColor: customColors.backgroundContainerColor,
            flexibleSpace: FlexibleSpaceBar(
              title: title,
              centerTitle: centerTitle,
              titlePadding: titlePadding,
              background: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: backgroundImage,
              ),
              expandedTitleScale: 1.1,
            ),
          ),
          if (appBarExtraWidgets != null)
            ...appBarExtraWidgets!(innerBoxIsScrolled),
        ];
      },
      body: child,
    );
  }
}

class SliverTabComponent extends StatelessWidget {
  final List<String> tabBarTitles;
  final Widget? title;
  final String? backgroundImageUrl;
  final List<Widget>? actions;
  final int crossAxisCount;
  final double childAspectRatio;
  final double expendedHeight;

  final List<Widget> Function(BuildContext context, String tabName)
      itemsBuilder;

  const SliverTabComponent({
    super.key,
    required this.tabBarTitles,
    this.title,
    this.backgroundImageUrl,
    this.actions,
    required this.crossAxisCount,
    this.childAspectRatio = 1,
    this.expendedHeight = 80,
    required this.itemsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return DefaultTabController(
      length: tabBarTitles.length,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(surfaceVariant: Colors.transparent),
              ),
              child: SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: title,
                  backgroundColor:
                      innerBoxIsScrolled ? customColors.backgroundColor : null,
                  centerTitle: true,
                  pinned: true,
                  floating: true,
                  snap: false,
                  // primary: false,
                  expandedHeight: expendedHeight,
                  elevation: 0,
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: backgroundImageUrl != null &&
                              backgroundImageUrl!.isNotEmpty
                          ? CachedNetworkImageEnhanced(
                              imageUrl: backgroundImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/background.webp',
                              fit: BoxFit.cover,
                            ),
                    ),
                    expandedTitleScale: 1.2,
                  ),
                  actions: actions,
                  bottom: TabBar(
                    tabs: tabBarTitles.map((e) => Tab(text: e)).toList(),
                    isScrollable: true,
                    labelColor: customColors.linkColor,
                    indicator: const BoxDecoration(),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: tabBarTitles.map(
            (e) {
              return Builder(
                builder: (context) {
                  final items = itemsBuilder(context, e);
                  return CustomScrollView(
                    key: PageStorageKey<String>(e),
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return items[index];
                            },
                            childCount: items.length, //内部控件数量
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 10,
                            childAspectRatio: childAspectRatio,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
