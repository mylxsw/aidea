import 'package:askaide/bloc/user_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/admin/users.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/credit.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
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

    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'User Info',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.card_giftcard_outlined),
              tooltip: 'Give Credits',
              onPressed: () {
                int sendCount = 600;
                String? note;
                int validDays = 30;

                openDialog(
                  context,
                  builder: Builder(builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Give Credits',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        EnhancedTextField(
                          labelText: 'Quantity',
                          customColors: customColors,
                          textAlignVertical: TextAlignVertical.top,
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          suffixIcon: Container(
                            width: 110,
                            alignment: Alignment.center,
                            child: Text(
                              'Credits',
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
                          labelText: 'Expiration',
                          customColors: customColors,
                          textAlignVertical: TextAlignVertical.top,
                          showCounter: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          suffixIcon: Container(
                            width: 110,
                            alignment: Alignment.center,
                            child: Text(
                              'Days',
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
                          labelText: 'Note',
                          customColors: customColors,
                          textAlignVertical: TextAlignVertical.top,
                          showCounter: false,
                          hintText: 'Optional',
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
                      showErrorMessage('Quantity must be greater than 0');
                      return false;
                    }

                    if (validDays <= 0) {
                      showErrorMessage('Expiration date must be greater than 0');
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
                      showSuccessMessage('Gift sent successfully');
                      context.read<UserBloc>().add(UserQuotaLoadEvent(widget.userId));
                    }).onError(
                      (error, stackTrace) => showErrorMessageEnhanced(context, error!),
                    );

                    return true;
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: customColors.backgroundColor,
        body: BackgroundContainer(
          setting: widget.setting,
          backgroundColor: customColors.backgroundColor,
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
                      listenWhen: (previous, current) => current is UserOperationResult,
                      listener: (context, state) {
                        if (state is UserOperationResult) {
                          if (state.success) {
                            showSuccessMessage(state.message ?? AppLocale.operateSuccess.getString(context));
                            context.read<UserBloc>().add(UserListLoadEvent());
                          } else {
                            showErrorMessage(state.message ?? AppLocale.operateFailed.getString(context));
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'ID',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: customColors.weakTextColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                '${state.user.id}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: customColors.weakTextColor,
                                                ),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        buildTags(context, customColors, state.user),
                                      ],
                                    ),
                                  ),
                                  buildUserAvatar(state.user, radius: CustomSize.borderRadiusAll),
                                ],
                              ),
                              TextItem(
                                title: 'Type',
                                value: state.user.userType ?? '-',
                              ),
                              if (state.user.phone != null && state.user.phone!.isNotEmpty)
                                TextItem(
                                  title: 'Photo',
                                  value: state.user.phone!,
                                ),
                              if (state.user.email != null && state.user.email!.isNotEmpty)
                                TextItem(
                                  title: 'Email',
                                  value: state.user.email!,
                                ),
                              if (state.user.realname != null && state.user.realname!.isNotEmpty)
                                TextItem(
                                  title: 'Nickname',
                                  value: state.user.realname!,
                                ),
                              if (state.user.invitedBy != null && state.user.invitedBy! > 0)
                                TextItem(
                                  title: 'Inviter ID',
                                  value: '${state.user.invitedBy}',
                                ),
                              if (state.user.createdAt != null)
                                TextItem(
                                  title: 'Creation time',
                                  value: state.user.createdAt!.toLocal().toString(),
                                ),
                              TextItem(
                                title: 'Status',
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
                      buildWhen: (previous, current) => current is UserQuotaLoaded,
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
                                title: 'Remaining credits',
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
            'Recharge History',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: customColors.weakTextColor,
            ),
          ),
          const SizedBox(height: 10),
          if (state.quota.details.isEmpty)
            const Text('No recharge record')
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
                          borderRadius: CustomSize.borderRadius,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (item.note == null || item.note == '') ? 'Buy' : item.note!,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        DateFormat(
                                          'yyyy/MM/dd HH:mm',
                                        ).format(item.createdAt.toLocal()),
                                        textScaler: const TextScaler.linear(0.8),
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
                                    Credit(
                                      count: item.quota,
                                      color: Colors.amber,
                                      withAddPrefix: true,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    Text(
                                      '${DateFormat('yyyy/MM/dd').format(item.periodEndAt.toLocal())} expired',
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
          borderRadius: const BorderRadius.only(topRight: CustomSize.radius, bottomLeft: CustomSize.radius),
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
