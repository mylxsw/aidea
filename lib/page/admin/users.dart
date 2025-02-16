import 'package:askaide/bloc/user_bloc.dart';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/pagination.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/admin/users.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class AdminUsersPage extends StatefulWidget {
  final SettingRepository setting;
  const AdminUsersPage({
    super.key,
    required this.setting,
  });

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  /// 当前页码
  int page = 1;

  /// 每页数量
  int perPage = 20;

  /// 搜索关键字
  final TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    context.read<UserBloc>().add(UserListLoadEvent(
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
            'User Management',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
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
                    context.read<UserBloc>().add(UserListLoadEvent(
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
                    context.read<UserBloc>().add(UserListLoadEvent(
                          perPage: perPage,
                          page: page,
                          keyword: keywordController.text,
                        ));
                  },
                  displacement: 20,
                  child: BlocConsumer<UserBloc, UserState>(
                    listener: (context, state) {
                      if (state is UserOperationResult) {
                        if (state.success) {
                          showSuccessMessage(state.message ?? AppLocale.operateSuccess.getString(context));
                          context.read<UserBloc>().add(UserListLoadEvent());
                        } else {
                          showErrorMessage(state.message ?? AppLocale.operateFailed.getString(context));
                        }
                      }

                      if (state is UsersLoaded) {
                        setState(() {
                          page = state.users.page;
                          perPage = state.users.perPage;
                        });
                      }
                    },
                    buildWhen: (previous, current) => current is UsersLoaded,
                    builder: (context, state) {
                      if (state is UsersLoaded) {
                        return SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: state.users.data.length,
                                  itemBuilder: (context, index) {
                                    return buildUserInfo(
                                      context,
                                      customColors,
                                      state.users.data[index],
                                    );
                                  },
                                ),
                              ),
                              if (state.users.lastPage != null && state.users.lastPage! > 1)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Pagination(
                                    numOfPages: state.users.lastPage ?? 1,
                                    selectedPage: page,
                                    pagesVisible: 5,
                                    onPageChanged: (selected) {
                                      context.read<UserBloc>().add(UserListLoadEvent(
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

  Widget buildUserInfo(
    BuildContext context,
    CustomColors customColors,
    AdminUser user,
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
              label: AppLocale.character.getString(context),
              borderRadius: const BorderRadius.only(
                topLeft: CustomSize.radius,
                bottomLeft: CustomSize.radius,
                topRight: CustomSize.radius,
                bottomRight: CustomSize.radius,
              ),
              backgroundColor: customColors.linkColor ?? Colors.green,
              icon: Icons.people,
              foregroundColor: Colors.white,
              onPressed: (_) {
                context.push('/admin/users/${user.id}/rooms');
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
              context.push('/admin/users/${user.id}');
            },
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 头像
                    Stack(
                      children: [
                        buildUserAvatar(user),
                        Positioned(
                          bottom: 0,
                          width: 70,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(bottomLeft: CustomSize.radius),
                            child: Container(
                              color: Colors.black.withAlpha(100),
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Center(
                                child: Text(
                                  '#${user.id}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                              user.displayName,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 5),
                            buildTags(context, customColors, user),
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
                          '${user.userType}',
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
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width / 2.0,
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.createdAt != null ? humanTime(user.createdAt) : '',
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

Widget buildUserAvatar(
  AdminUser user, {
  BorderRadius radius = const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
}) {
  if (user.avatar != null && user.avatar!.startsWith('http')) {
    return SizedBox(
      width: 70,
      height: 70,
      child: ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: imageURL(user.avatar!, qiniuImageTypeAvatar),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  return Initicon(
    text: user.displayName.split('、').join(' '),
    size: 70,
    backgroundColor: Colors.grey.withAlpha(100),
    borderRadius: radius,
  );
}

Widget buildTags(BuildContext context, CustomColors customColors, AdminUser user) {
  final tags = <Widget>[];

  if (user.email != null && user.email!.isNotEmpty) {
    tags.add(buildTag(context, customColors, 'Email'));
  }

  if (user.phone != null && user.phone!.isNotEmpty) {
    tags.add(buildTag(context, customColors, 'Phone'));
  }

  if (user.unionId != null && user.unionId!.isNotEmpty) {
    tags.add(buildTag(context, customColors, 'WeChat'));
  }

  if (user.appleUid != null && user.appleUid!.isNotEmpty) {
    tags.add(buildTag(context, customColors, 'Apple'));
  }

  return Wrap(
    spacing: 5,
    runSpacing: 5,
    children: tags,
  );
}

Widget buildTag(BuildContext context, CustomColors customColors, String s) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 5,
      vertical: 2,
    ),
    decoration: BoxDecoration(
      color: customColors.tagsBackground,
      borderRadius: CustomSize.borderRadius,
    ),
    child: Text(
      s,
      style: TextStyle(
        fontSize: 10,
        color: customColors.tagsText,
      ),
    ),
  );
}
