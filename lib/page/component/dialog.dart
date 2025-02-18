import 'dart:ui';

import 'package:askaide/helper/event.dart';
import 'package:askaide/helper/haptic_feedback.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/bottom_sheet_box.dart';
import 'package:askaide/page/component/button.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';

showErrorMessageEnhanced(
  BuildContext context,
  Object message, {
  Duration duration = const Duration(seconds: 5),
}) {
  if (message is LanguageText) {
    switch (message.action) {
      // 智慧果不足，支付页面
      case 'payment':
        showBeautyDialog(
          context,
          type: QuickAlertType.warning,
          text: message.message.getString(context),
          confirmBtnText: AppLocale.buy.getString(context),
          showCancelBtn: true,
          onConfirmBtnTap: () {
            context.pop();
            context.push('/payment');
          },
        );
        return;
      // 需要重新登录
      case 're-signin':
        showBeautyDialog(
          context,
          type: QuickAlertType.warning,
          text: message.message.getString(context),
          confirmBtnText: AppLocale.reSignIn.getString(context),
          showCancelBtn: true,
          onConfirmBtnTap: () {
            context.pop();
            context.push('/login');
          },
        );
        return;
      // 需要登录
      case 'sign-in':
        showBeautyDialog(
          context,
          type: QuickAlertType.warning,
          text: AppLocale.needSigninToUse.getString(context),
          onConfirmBtnTap: () {
            context.pop();
            context.push('/login');
          },
          showCancelBtn: true,
          confirmBtnText: AppLocale.signinNow.getString(context),
        );
        return;
    }

    showErrorMessage(message.message.getString(context), duration: duration);
    return;
  }

  showErrorMessage(message.toString(), duration: duration);
}

showCustomBeautyDialog(
  BuildContext context, {
  required QuickAlertType type,
  required Widget child,
  String confirmBtnText = '',
  String? cancelBtnText,
  Function()? onConfirmBtnTap,
  Function()? onCancelBtnTap,
  bool showCancelBtn = false,
  String title = '',
}) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  QuickAlert.show(
    context: context,
    type: type,
    widget: child,
    width: MediaQuery.of(context).size.width > 600 ? 400 : null,
    barrierDismissible: false, // 禁止点击外部关闭
    showCancelBtn: showCancelBtn,
    confirmBtnText: confirmBtnText == '' ? AppLocale.ok.getString(context) : confirmBtnText,
    cancelBtnText: cancelBtnText ?? AppLocale.cancel.getString(context),
    confirmBtnColor: customColors.linkColor!,
    borderRadius: CustomSize.radiusValue,
    buttonBorderRadius: CustomSize.radiusValue,
    backgroundColor: customColors.dialogBackgroundColor!,
    confirmBtnTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.normal,
    ),
    title: title,
    titleColor: customColors.dialogDefaultTextColor!,
    textColor: customColors.dialogDefaultTextColor!,
    cancelBtnTextStyle: TextStyle(
      color: customColors.dialogDefaultTextColor,
      fontWeight: FontWeight.normal,
    ),
    onConfirmBtnTap: onConfirmBtnTap,
    onCancelBtnTap: onCancelBtnTap,
  );
}

Future<dynamic> showBeautyDialog(
  BuildContext context, {
  required QuickAlertType type,
  String? text,
  String? title,
  String? customAsset,
  Widget? widget,
  String confirmBtnText = '',
  String? cancelBtnText,
  Function()? onConfirmBtnTap,
  Function()? onCancelBtnTap,
  bool showCancelBtn = false,
  bool barrierDismissible = false, // 禁止点击外部关闭
}) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  return QuickAlert.show(
    context: context,
    type: type,
    text: text,
    customAsset: customAsset,
    widget: widget,
    width: MediaQuery.of(context).size.width > 600 ? 400 : null,
    barrierDismissible: barrierDismissible,
    showCancelBtn: showCancelBtn,
    confirmBtnText: confirmBtnText == '' ? AppLocale.ok.getString(context) : confirmBtnText,
    cancelBtnText: cancelBtnText ?? AppLocale.cancel.getString(context),
    confirmBtnColor: customColors.linkColor!,
    borderRadius: CustomSize.radiusValue,
    buttonBorderRadius: CustomSize.radiusValue,
    backgroundColor: customColors.dialogBackgroundColor!,
    confirmBtnTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.normal,
    ),
    title: title ?? '',
    titleColor: customColors.dialogDefaultTextColor!,
    textColor: customColors.dialogDefaultTextColor!,
    cancelBtnTextStyle: TextStyle(
      color: customColors.dialogDefaultTextColor,
      fontWeight: FontWeight.normal,
    ),
    onConfirmBtnTap: onConfirmBtnTap,
    onCancelBtnTap: onCancelBtnTap,
  );
}

showErrorMessage(String message, {Duration duration = const Duration(seconds: 3)}) {
  HapticFeedbackHelper.mediumImpact();
  Logger.instance.e(message);

  BotToast.showText(
    text: message,
    duration: duration,
    textStyle: const TextStyle(
      fontSize: 15,
      color: Colors.white,
    ),
    align: Alignment.center,
  );
}

showSuccessMessage(String message, {Duration duration = const Duration(seconds: 3)}) async {
  BotToast.showText(
    text: message,
    duration: duration,
    textStyle: const TextStyle(
      fontSize: 15,
      color: Colors.white,
    ),
    align: Alignment.center,
  );
}

showImportantMessage(BuildContext context, String message) {
  openModalBottomSheet(
    context,
    (context) {
      return Container(
        padding: const EdgeInsets.all(10),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      );
    },
    heightFactor: 0.1,
  );
}

Future openModalBottomSheet(
  BuildContext context,
  Widget Function(BuildContext context) builder, {
  bool useSafeArea = false,
  isScrollControlled = true,
  double heightFactor = 0.5,
  String? title,
  bool disableEvent = false,
  bool disableCompleteEvent = false,
  bool disableInitEvent = false,
}) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  if (!disableEvent && !disableInitEvent) {
    GlobalEvent().emit('hideBottomNavigatorBar');
  }

  return showModalBottomSheet(
    context: context,
    useSafeArea: useSafeArea,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: CustomSize.radius),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BottomSheetBox(
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildBottomSheetTopBar(customColors),
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: customColors.weakTextColorPlus,
                  ),
                ),
              if (title != null) const SizedBox(height: 10),
              Expanded(
                child: builder(context),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(() {
    if (!disableEvent && !disableCompleteEvent) {
      GlobalEvent().emit('showBottomNavigatorBar');
    }
  });
}

openConfirmDialog(
  BuildContext context,
  String message,
  Function() onConfirm, {
  Widget? title,
  bool danger = false,
  String? confirmText,
  String? cancelText,
}) {
  HapticFeedbackHelper.mediumImpact();
  final customColors = Theme.of(context).extension<CustomColors>()!;

  GlobalEvent().emit('hideBottomNavigatorBar');
  showModalBottomSheet(
    context: context,
    elevation: 0,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BottomSheetBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildBottomSheetTopBar(customColors),
            const SizedBox(height: 10),
            if (title != null) title,
            if (title != null && message != '') const SizedBox(height: 10),
            if (message != '')
              Text(
                message,
                style: TextStyle(
                  color: customColors.dialogDefaultTextColor,
                  fontSize: title == null ? 16 : 12,
                ),
                textAlign: TextAlign.center,
                maxLines: title == null ? 4 : 2,
              ),
            const SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  title: confirmText ?? AppLocale.ok.getString(context),
                  onPressed: () {
                    onConfirm();
                    context.pop();
                  },
                  size: const ButtonSize.full(),
                  color: danger ? const Color.fromARGB(255, 255, 17, 0) : customColors.linkColor,
                  backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                ),
                const SizedBox(height: 10),
                Button(
                  title: cancelText ?? AppLocale.cancel.getString(context),
                  backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                  color: customColors.dialogDefaultTextColor?.withAlpha(150),
                  onPressed: () {
                    context.pop();
                  },
                  size: const ButtonSize.full(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      );
    },
  ).whenComplete(() => GlobalEvent().emit('showBottomNavigatorBar'));

  // showDialog(
  //   context: context,
  //   builder: (_) {
  //     return SizedBox(
  //       width: _calDialogWidth(context),
  //       child: CustomDialog(
  //         customColors: customColors,
  //         title: title ?? Container(),
  //         content: Text(
  //           message,
  //           style: TextStyle(color: customColors.dialogDefaultTextColor),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               context.pop();
  //             },
  //             style: TextButton.styleFrom(
  //               foregroundColor: Colors.grey,
  //             ),
  //             child: Text(
  //               AppLocale.cancel.getString(context),
  //               style: TextStyle(color: customColors.dialogDefaultTextColor),
  //             ),
  //           ),
  //           const SizedBox(width: 10),
  //           Button(
  //             title: AppLocale.ok.getString(context),
  //             onPressed: () {
  //               onConfirm();
  //               context.pop();
  //             },
  //             // backgroundColor: danger ? Colors.red : null,
  //           ),
  //         ],
  //       ),
  //     );
  //   },
  // );
}

Center buildBottomSheetTopBar(CustomColors customColors) {
  return Center(
    child: FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 10),
        height: 4,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 192, 192, 192),
          borderRadius: CustomSize.borderRadius,
          border: Border.all(
            color: Colors.black12,
            width: 0.5,
          ),
        ),
      ),
    ),
  );
}

Future<T?> openDialog<T>(
  BuildContext context, {
  Widget? title,
  required Builder builder,
  required bool Function() onSubmit,
  Function()? afterSubmit,
  bool showCancel = true,
  String? confirmText,
  bool barrierDismissible = true,
}) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  return showDialog(
    context: context,
    builder: (context) => CustomDialog(
      title: title,
      customColors: customColors,
      content: SizedBox(
        width: _calDialogWidth(context),
        child: builder.build(context),
      ),
      actions: [
        if (showCancel)
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              AppLocale.cancel.getString(context),
              style: TextStyle(color: customColors.dialogDefaultTextColor),
            ),
          ),
        Button(
          onPressed: () {
            if (onSubmit()) {
              context.pop();
            }

            if (afterSubmit != null) {
              afterSubmit();
            }
          },
          title: confirmText ?? AppLocale.ok.getString(context),
          backgroundColor: const Color.fromARGB(36, 222, 222, 222),
          color: customColors.linkColor,
        )
      ],
    ),
    barrierDismissible: barrierDismissible,
  );
}

double _calDialogWidth(BuildContext context) {
  final windowWidth = MediaQuery.of(context).size.width * 0.8;
  if (windowWidth > 350) {
    return 350;
  }

  return windowWidth;
}

openListSelectDialogWithDatasource<T>({
  required bool Function(SelectorItem value) onSelected,
  required BuildContext context,
  required Future<List<T>>? future,
  required SelectorItem Function(T value) itemBuilder,
  double heightFactor = 0.5,
  bool enableSearch = false,
  String? title,
  Object? value,
  bool horizontal = false,
  int horizontalCount = 4,
  EdgeInsets? innerPadding,
}) {
  openModalBottomSheet(
    context,
    (context) {
      return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ItemSearchSelector(
            enableSearch: enableSearch,
            items: (snapshot.data ?? []).map((e) => itemBuilder(e)).toList(),
            onSelected: onSelected,
            value: value,
            horizontal: horizontal,
            horizontalCount: horizontalCount,
            innerPadding: innerPadding,
          );
        },
      );
    },
    heightFactor: heightFactor,
    title: title,
  );
}

openListSelectDialog(
  BuildContext context,
  List<SelectorItem> items,
  bool Function(SelectorItem value) onSelected, {
  double heightFactor = 0.5,
  bool enableSearch = false,
  String? title,
  Object? value,
  bool horizontal = false,
  int horizontalCount = 4,
  EdgeInsets? innerPadding,
}) {
  openModalBottomSheet(
    context,
    (context) {
      return ItemSearchSelector(
        enableSearch: enableSearch,
        items: items,
        onSelected: onSelected,
        value: value,
        horizontal: horizontal,
        horizontalCount: horizontalCount,
        innerPadding: innerPadding,
      );
    },
    heightFactor: heightFactor,
    title: title,
  );
}

/// 弹出一个输入框
openTextFieldDialog(
  BuildContext context, {
  required String title,
  String? hint,
  String? defaultValue,
  int? maxLine,
  bool obscureText = false,
  int? maxLength,
  Icon? suffixIcon,
  bool withSuffixIcon = false,
  bool showCounter = false,
  bool enableSearch = false,
  List<SelectorItem<String>>? dataSources,
  Future<List<SelectorItem<String>>>? futureDataSources,
  required bool Function(String) onSubmit,
}) {
  final customColors = Theme.of(context).extension<CustomColors>()!;
  final controller = TextEditingController(text: defaultValue ?? '');
  GlobalEvent().emit('hideBottomNavigatorBar');
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return BottomSheetBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBottomSheetTopBar(customColors),
            EnhancedTextField(
              enableBackground: true,
              labelPosition: LabelPosition.top,
              labelText: title,
              customColors: customColors,
              controller: controller,
              maxLines: obscureText ? 1 : maxLine,
              obscureText: obscureText,
              maxLength: maxLength,
              showCounter: showCounter,
              hintText: hint,
              inputSelector: withSuffixIcon
                  ? IconButton(
                      icon: suffixIcon ??
                          Icon(
                            Icons.style,
                            color: customColors.dialogDefaultTextColor,
                            size: 16,
                          ),
                      onPressed: () {
                        openModalBottomSheet(
                          context,
                          (context) {
                            if (futureDataSources != null) {
                              return FutureBuilder(
                                future: futureDataSources,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ItemSearchSelector(
                                      items: snapshot.data as List<SelectorItem>,
                                      onSelected: (value) {
                                        controller.text = value.value;
                                        return true;
                                      },
                                      enableSearch: enableSearch,
                                    );
                                  }

                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );
                            }

                            return ItemSearchSelector(
                              items: dataSources ?? [],
                              onSelected: (value) {
                                controller.text = value.value;
                                return true;
                              },
                              enableSearch: enableSearch,
                            );
                          },
                          disableEvent: true,
                        );
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  title: AppLocale.ok.getString(context),
                  backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                  color: customColors.linkColor,
                  onPressed: () {
                    if (onSubmit(controller.text)) {
                      context.pop();
                    }
                  },
                  size: const ButtonSize.full(),
                  // backgroundColor: danger ? Colors.red : null,
                ),
                const SizedBox(height: 10),
                Button(
                  title: AppLocale.cancel.getString(context),
                  backgroundColor: const Color.fromARGB(36, 222, 222, 222),
                  color: customColors.dialogDefaultTextColor?.withAlpha(150),
                  onPressed: () {
                    context.pop();
                  },
                  size: const ButtonSize.full(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      );
    },
  ).whenComplete(() {
    GlobalEvent().emit('showBottomNavigatorBar');
    Future.delayed(const Duration(seconds: 1), () {
      controller.dispose();
    });
  });
}

openFullscreenDialog(
  BuildContext context, {
  required Widget child,
  required String title,
  List<Widget>? actions,
}) {
  HapticFeedbackHelper.mediumImpact();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _FullScreenDialog(
        title: title,
        actions: actions,
        child: child,
      ),
    ),
  );
}

@immutable
class _FullScreenDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const _FullScreenDialog({
    Key? key,
    required this.title,
    required this.child,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          toolbarHeight: CustomSize.toolbarHeight,
          actions: actions,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: customColors.backgroundColor,
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? title;
  final Widget? content;
  final Color? backgroundColor;
  final bool glassEffect;
  final CustomColors customColors;

  const CustomDialog({
    super.key,
    required this.customColors,
    this.actions,
    this.title,
    this.content,
    this.backgroundColor,
    this.glassEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    final dialog = AlertDialog(
      title: title,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: CustomSize.borderRadius),
      titleTextStyle: TextStyle(
        color: customColors.dialogDefaultTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: backgroundColor ??
          (glassEffect ? customColors.dialogBackgroundColor!.withAlpha(50) : customColors.dialogBackgroundColor),
      content: content,
      actions: actions,
      actionsAlignment: MainAxisAlignment.spaceAround,
    );

    if (glassEffect) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: dialog,
        ),
      );
    }

    return dialog;
  }
}
