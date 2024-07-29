import 'package:askaide/bloc/user_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/admin/users.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/coin.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/creative_island/gallery/gallery_item.dart';
import 'package:askaide/repo/api/quota.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

class AdminUserPage extends StatefulWidget {
  final SettingRepository setting;
  final int userId;
  const AdminUserPage({
    super.key,
    required this.setting,
    required this.userId,
  });

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  @override
  void initState() {
    context.read<UserBloc>().add(UserLoadEvent(widget.userId));
    context.read<UserBloc>().add(UserQuotaLoadEvent(widget.userId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        title: const Text(
          '用户详情',
          style: TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_outlined),
            tooltip: '赠送智慧果',
            onPressed: () {
              int sendCount = 1000;
              String? note;
              int validDays = 365;

              openDialog(
                context,
                builder: Builder(builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '赠送智慧果',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      EnhancedTextField(
                        labelText: '数量',
                        customColors: customColors,
                        textAlignVertical: TextAlignVertical.top,
                        showCounter: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        suffixIcon: Container(
                          width: 110,
                          alignment: Alignment.center,
                          child: Text(
                            '个智慧果',
                            style: TextStyle(
                              color: customColors.weakTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          sendCount = int.tryParse(value) ?? 0;
                        },
                        initValue: sendCount.toString(),
                      ),
                      const SizedBox(height: 10),
                      EnhancedTextField(
                        labelText: '有效期',
                        customColors: customColors,
                        textAlignVertical: TextAlignVertical.top,
                        showCounter: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        suffixIcon: Container(
                          width: 110,
                          alignment: Alignment.center,
                          child: Text(
                            '天',
                            style: TextStyle(
                              color: customColors.weakTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          validDays = int.tryParse(value) ?? 0;
                        },
                        initValue: validDays.toString(),
                      ),
                      const SizedBox(height: 10),
                      EnhancedTextField(
                        labelText: '备注',
                        customColors: customColors,
                        textAlignVertical: TextAlignVertical.top,
                        showCounter: false,
                        hintText: '可选',
                        onChanged: (value) {
                          note = value;
                        },
                        initValue: note,
                      ),
                    ],
                  );
                }),
                onSubmit: () {
                  if (sendCount <= 0) {
                    showErrorMessage('数量必须大于 0');
                    return false;
                  }

                  if (validDays <= 0) {
                    showErrorMessage('有效期必须大于 0');
                    return false;
                  }

                  APIServer()
                      .adminUserQuotaAssign(
                    userId: widget.userId,
                    quota: sendCount,
                    validPeriod: validDays * 24,
                    note: note,
                  )
                      .then((value) {
                    showSuccessMessage('赠送成功');
                    context
                        .read<UserBloc>()
                        .add(UserQuotaLoadEvent(widget.userId));
                  }).onError(
                    (error, stackTrace) =>
                        showErrorMessageEnhanced(context, error!),
                  );

                  return true;
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: customColors.chatInputPanelBackground,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: RefreshIndicator(
          color: customColors.linkColor,
          onRefresh: () async {
            context.read<UserBloc>().add(UserLoadEvent(widget.userId));
            context.read<UserBloc>().add(UserQuotaLoadEvent(widget.userId));
          },
          displacement: 20,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocConsumer<UserBloc, UserState>(
                    listenWhen: (previous, current) =>
                        current is UserOperationResult,
                    listener: (context, state) {
                      if (state is UserOperationResult) {
                        if (state.success) {
                          showSuccessMessage(state.message ??
                              AppLocale.operateSuccess.getString(context));
                          context.read<UserBloc>().add(UserListLoadEvent());
                        } else {
                          showErrorMessage(state.message ??
                              AppLocale.operateFailed.getString(context));
                        }
                      }
                    },
                    buildWhen: (previous, current) => current is UserLoaded,
                    builder: (context, state) {
                      if (state is UserLoaded) {
                        return ColumnBlock(
                          innerPanding: 10,
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.all(15),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'ID',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    customColors.weakTextColor,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${state.user.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    customColors.weakTextColor,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      buildTags(
                                          context, customColors, state.user),
                                    ],
                                  ),
                                ),
                                buildUserAvatar(
                                  state.user,
                                  radius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            TextItem(
                              title: '类型',
                              value: state.user.userType ?? '-',
                            ),
                            if (state.user.phone != null &&
                                state.user.phone!.isNotEmpty)
                              TextItem(
                                title: '手机号',
                                value: state.user.phone!,
                              ),
                            if (state.user.email != null &&
                                state.user.email!.isNotEmpty)
                              TextItem(
                                title: '邮箱',
                                value: state.user.email!,
                              ),
                            if (state.user.realname != null &&
                                state.user.realname!.isNotEmpty)
                              TextItem(
                                title: '昵称',
                                value: state.user.realname!,
                              ),
                            if (state.user.invitedBy != null &&
                                state.user.invitedBy! > 0)
                              TextItem(
                                title: '邀请人 ID',
                                value: '${state.user.invitedBy}',
                              ),
                            if (state.user.createdAt != null)
                              TextItem(
                                title: '注册时间',
                                value:
                                    state.user.createdAt!.toLocal().toString(),
                              ),
                            TextItem(
                              title: '状态',
                              value: state.user.status ?? '-',
                            ),
                          ],
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(
                          color: customColors.linkColor,
                        ),
                      );
                    },
                  ),
                  BlocBuilder<UserBloc, UserState>(
                    buildWhen: (previous, current) =>
                        current is UserQuotaLoaded,
                    builder: (context, state) {
                      if (state is UserQuotaLoaded) {
                        return ColumnBlock(
                          innerPanding: 10,
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 15,
                          ),
                          children: [
                            TextItem(
                              title: '剩余智慧果',
                              value: state.quota.total.toString(),
                            ),
                            buildPaymentDetails(customColors, state)
                          ],
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(
                          color: customColors.linkColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 购买历史记录
  Widget buildPaymentDetails(
    CustomColors customColors,
    UserQuotaLoaded state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '充值历史',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: customColors.weakTextColor,
            ),
          ),
          const SizedBox(height: 10),
          if (state.quota.details.isEmpty)
            const Text('无充值记录')
          else
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var item in state.quota.details)
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 10,
                          left: 16,
                          right: 16,
                        ),
                        decoration: BoxDecoration(
                          color: customColors.paymentItemBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (item.note == null || item.note == '')
                                            ? '购买'
                                            : item.note!,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        DateFormat(
                                          'yyyy/MM/dd HH:mm',
                                        ).format(item.createdAt.toLocal()),
                                        textScaler:
                                            const TextScaler.linear(0.8),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Coin(
                                      count: item.quota,
                                      color: Colors.amber,
                                      withAddPrefix: true,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    Text(
                                      '${DateFormat('yyyy/MM/dd').format(item.periodEndAt.toLocal())} 过期',
                                      textScaler: const TextScaler.linear(0.7),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildTagForItem(item),
                    ],
                  )
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTagForItem(QuotaDetail item) {
    if (item.rest <= 0) {
      return _buildTag(AppLocale.usedUp.getString(context), Colors.orange);
    }

    if (item.expired) {
      return _buildTag(AppLocale.expired.getString(context), Colors.grey[600]!);
    }

    return const SizedBox();
  }

  Widget _buildTag(String text, Color color) {
    return Positioned(
      right: 1,
      top: 7,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(9),
            bottomLeft: Radius.circular(9),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 2,
        ),
        child: Text(
          text,
          textScaler: const TextScaler.linear(0.6),
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
