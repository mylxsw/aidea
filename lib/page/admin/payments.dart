import 'package:askaide/bloc/admin_payment_bloc.dart';
import 'package:askaide/bloc/user_bloc.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/pagination.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/admin/payment.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentHistoriesPage extends StatefulWidget {
  final SettingRepository setting;
  const PaymentHistoriesPage({
    super.key,
    required this.setting,
  });

  @override
  State<PaymentHistoriesPage> createState() => _PaymentHistoriesPageState();
}

class _PaymentHistoriesPageState extends State<PaymentHistoriesPage> {
  /// 当前页码
  int page = 1;

  /// 每页数量
  int perPage = 20;

  /// 搜索关键字
  final TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    context.read<AdminPaymentBloc>().add(AdminPaymentHistoriesLoadEvent(
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
            'Payment Order History',
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
                    context.read<AdminPaymentBloc>().add(AdminPaymentHistoriesLoadEvent(
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
                    context.read<AdminPaymentBloc>().add(AdminPaymentHistoriesLoadEvent(
                          perPage: perPage,
                          page: page,
                          keyword: keywordController.text,
                        ));
                  },
                  displacement: 20,
                  child: BlocConsumer<AdminPaymentBloc, AdminPaymentState>(
                    listener: (context, state) {
                      if (state is AdminPaymentOperationResult) {
                        if (state.success) {
                          showSuccessMessage(state.message);
                          context.read<UserBloc>().add(UserListLoadEvent());
                        } else {
                          showErrorMessage(state.message);
                        }
                      }

                      if (state is AdminPaymentHistoriesLoaded) {
                        setState(() {
                          page = state.histories.page;
                          perPage = state.histories.perPage;
                        });
                      }
                    },
                    buildWhen: (previous, current) => current is AdminPaymentHistoriesLoaded,
                    builder: (context, state) {
                      if (state is AdminPaymentHistoriesLoaded) {
                        return SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: state.histories.data.length,
                                  itemBuilder: (context, index) {
                                    return buildHistoryInfo(
                                      context,
                                      customColors,
                                      state.histories.data[index],
                                    );
                                  },
                                ),
                              ),
                              if (state.histories.lastPage != null && state.histories.lastPage! > 1)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Pagination(
                                    numOfPages: state.histories.lastPage ?? 1,
                                    selectedPage: page,
                                    pagesVisible: 5,
                                    onPageChanged: (selected) {
                                      context.read<AdminPaymentBloc>().add(AdminPaymentHistoriesLoadEvent(
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

  Widget buildHistoryInfo(
    BuildContext context,
    CustomColors customColors,
    AdminPaymentHistory his,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(borderRadius: CustomSize.borderRadius),
      child: Slidable(
        child: Material(
          borderRadius: CustomSize.borderRadius,
          color: customColors.columnBlockBackgroundColor,
          child: InkWell(
            borderRadius: CustomSize.borderRadiusAll,
            onTap: () {
              context.push('/admin/users/${his.userId}');
            },
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 头像
                    buildAvatar(his, radius: CustomSize.borderRadiusAll),
                    // 名称
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '@${his.userId} Charge ',
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '￥${(his.retailPrice / 100).ceil()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '#${his.id}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: customColors.weakTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            buildTags(context, customColors, his),
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
                          his.environment,
                          style: TextStyle(
                            fontSize: 10,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            color:
                                his.environment.toLowerCase() == 'production' ? customColors.linkColor : Colors.amber,
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
                          DateFormat('y-MM-dd HH:mm').format(his.purchaseAt.toLocal()),
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

Widget buildAvatar(
  AdminPaymentHistory his, {
  BorderRadius radius = const BorderRadius.only(topLeft: CustomSize.radius, bottomLeft: CustomSize.radius),
}) {
  final source = (his.source ?? '').toLowerCase();

  var image = '';
  if (source.contains('支付宝') || source.contains('alipay')) {
    image = 'assets/zhifubao.png';
  } else if (source.contains('微信') || source.contains('wechat')) {
    image = 'assets/wechat-pay.png';
  } else if (source.contains('stripe')) {
    image = 'assets/stripe.png';
  } else if (source.contains('apple')) {
    image = 'assets/apple.webp';
  } else {
    image = 'assets/app.png';
  }

  return SizedBox(
    width: 70,
    height: 70,
    child: ClipRRect(
      borderRadius: radius,
      child: Image.asset(image),
    ),
  );
}

Widget buildTags(BuildContext context, CustomColors customColors, AdminPaymentHistory his) {
  final tags = <Widget>[];

  if (his.source != null) {
    tags.add(buildTag(context, customColors, his.source!));
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
    decoration: BoxDecoration(color: customColors.tagsBackground, borderRadius: CustomSize.borderRadius),
    child: Text(
      s,
      style: TextStyle(
        fontSize: 10,
        color: customColors.tagsText,
      ),
    ),
  );
}
