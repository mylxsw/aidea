import 'dart:ui';

import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    this.borderRadius,
    this.appBarBackgroundImage,
    this.appBarBackgroundImageForRoom,
    this.appBarBackgroundImageForCreativeIsland,
    this.appBarBackgroundImageDiscovery,
    this.chatRoomBackground,
    this.chatRoomReplyBackground,
    this.chatRoomReplyBackgroundSecondary,
    this.chatRoomReplyText,
    this.chatRoomSenderBackground,
    this.chatRoomSenderBackgroundSecondary,
    this.chatRoomSenderBackgroundWarning,
    this.chatRoomSenderText,
    this.tagsBackground,
    this.tagsBackgroundHover,
    this.tagsText,
    this.chatInputPanelBackground,
    this.chatInputPanelText,
    this.chatInputAreaBackground,
    this.chatExampleItemBackground,
    this.chatExampleItemBackgroundHover,
    this.chatExampleItemText,
    this.chatExampleTitleText,
    this.markdownLinkColor,
    this.markdownPreColor,
    this.markdownCodeColor,
    this.boxShadowColor,
    this.backgroundColor,
    this.backgroundInvertedColor,
    this.backgroundContainerColor,
    this.textFieldBorderColor,
    this.iconButtonColor,
    this.linkColor,
    this.weakLinkColor,
    this.weakTextColor,
    this.weakTextColorPlus,
    this.weakTextColorPlusPlus,
    this.dialogDefaultTextColor,
    this.dialogBackgroundColor,
    this.columnBlockBorderColor,
    this.columnBlockBackgroundColor,
    this.columnBlockDividerColor,
    this.textfieldHintColor,
    this.textfieldHintDeepColor,
    this.textfieldLabelColor,
    this.textfieldValueColor,
    this.textfieldBackgroundColor,
    this.textfieldSelectorColor,
    this.paymentItemBorderColor,
    this.paymentItemBackgroundColor,
    this.paymentItemTitleColor,
    this.paymentItemPriceColor,
    this.paymentItemDateColor,
    this.paymentItemDescriptionColor,
  });

  final double? borderRadius;

  final String? appBarBackgroundImage;
  final String? appBarBackgroundImageForRoom;
  final String? appBarBackgroundImageForCreativeIsland;
  final String? appBarBackgroundImageDiscovery;

  final Color? chatRoomBackground;
  final Color? chatRoomReplyBackground;
  final Color? chatRoomReplyBackgroundSecondary;
  final Color? chatRoomReplyText;
  final Color? chatRoomSenderBackground;
  final Color? chatRoomSenderBackgroundSecondary;
  final Color? chatRoomSenderBackgroundWarning;
  final Color? chatRoomSenderText;
  final Color? tagsBackground;
  final Color? tagsBackgroundHover;
  final Color? tagsText;

  final Color? chatInputPanelBackground;
  final Color? chatInputPanelText;
  final Color? chatInputAreaBackground;

  final Color? chatExampleItemBackground;
  final Color? chatExampleItemBackgroundHover;

  final Color? chatExampleItemText;
  final Color? chatExampleTitleText;

  final Color? markdownLinkColor;
  final Color? markdownPreColor;
  final Color? markdownCodeColor;

  final Color? boxShadowColor;
  final Color? backgroundColor;
  final Color? backgroundInvertedColor;
  final Color? backgroundContainerColor;

  final Color? textFieldBorderColor;
  final Color? iconButtonColor;

  final Color? linkColor;
  final Color? weakLinkColor;
  final Color? weakTextColor;
  final Color? weakTextColorPlus;
  final Color? weakTextColorPlusPlus;

  final Color? dialogDefaultTextColor;
  final Color? dialogBackgroundColor;

  final Color? columnBlockBorderColor;
  final Color? columnBlockBackgroundColor;
  final Color? columnBlockDividerColor;

  final Color? textfieldHintColor;
  final Color? textfieldHintDeepColor;
  final Color? textfieldLabelColor;
  final Color? textfieldValueColor;
  final Color? textfieldBackgroundColor;
  final Color? textfieldSelectorColor;

  final Color? paymentItemBorderColor;
  final Color? paymentItemBackgroundColor;
  final Color? paymentItemTitleColor;
  final Color? paymentItemPriceColor;
  final Color? paymentItemDateColor;
  final Color? paymentItemDescriptionColor;

  @override
  ThemeExtension<CustomColors> lerp(
    covariant ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }

    return CustomColors(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
      appBarBackgroundImage: appBarBackgroundImage,
      appBarBackgroundImageForRoom: appBarBackgroundImageForRoom,
      appBarBackgroundImageForCreativeIsland:
          appBarBackgroundImageForCreativeIsland,
      appBarBackgroundImageDiscovery: appBarBackgroundImageDiscovery,
      chatRoomBackground:
          Color.lerp(chatRoomBackground, other.chatRoomBackground, t),
      chatRoomReplyBackground:
          Color.lerp(chatRoomReplyBackground, other.chatRoomReplyBackground, t),
      chatRoomReplyBackgroundSecondary: Color.lerp(
          chatRoomReplyBackgroundSecondary,
          other.chatRoomReplyBackgroundSecondary,
          t),
      chatRoomReplyText:
          Color.lerp(chatRoomReplyText, other.chatRoomReplyText, t),
      chatRoomSenderBackground: Color.lerp(
          chatRoomSenderBackground, other.chatRoomSenderBackground, t),
      chatRoomSenderBackgroundSecondary: Color.lerp(
          chatRoomSenderBackgroundSecondary,
          other.chatRoomSenderBackgroundSecondary,
          t),
      chatRoomSenderBackgroundWarning: Color.lerp(
          chatRoomSenderBackgroundWarning,
          other.chatRoomSenderBackgroundWarning,
          t),
      chatRoomSenderText:
          Color.lerp(chatRoomSenderText, other.chatRoomSenderText, t),
      tagsBackground: Color.lerp(tagsBackground, other.tagsBackground, t),
      tagsBackgroundHover:
          Color.lerp(tagsBackgroundHover, other.tagsBackgroundHover, t),
      tagsText: Color.lerp(tagsText, other.tagsText, t),
      chatInputPanelBackground: Color.lerp(
          chatInputPanelBackground, other.chatInputPanelBackground, t),
      chatInputPanelText:
          Color.lerp(chatInputPanelText, other.chatInputPanelText, t),
      chatInputAreaBackground:
          Color.lerp(chatInputAreaBackground, other.chatInputAreaBackground, t),
      chatExampleItemBackground: Color.lerp(
          chatExampleItemBackground, other.chatExampleItemBackground, t),
      chatExampleItemBackgroundHover: Color.lerp(chatExampleItemBackgroundHover,
          other.chatExampleItemBackgroundHover, t),
      chatExampleItemText:
          Color.lerp(chatExampleItemText, other.chatExampleItemText, t),
      chatExampleTitleText:
          Color.lerp(chatExampleTitleText, other.chatExampleTitleText, t),
      markdownLinkColor:
          Color.lerp(markdownLinkColor, other.markdownLinkColor, t),
      markdownPreColor: Color.lerp(markdownPreColor, other.markdownPreColor, t),
      markdownCodeColor:
          Color.lerp(markdownCodeColor, other.markdownCodeColor, t),
      boxShadowColor: Color.lerp(boxShadowColor, other.boxShadowColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      backgroundInvertedColor:
          Color.lerp(backgroundInvertedColor, other.backgroundInvertedColor, t),
      backgroundContainerColor: Color.lerp(
          backgroundContainerColor, other.backgroundContainerColor, t),
      textFieldBorderColor:
          Color.lerp(textFieldBorderColor, other.textFieldBorderColor, t),
      iconButtonColor: Color.lerp(iconButtonColor, other.iconButtonColor, t),
      weakLinkColor: Color.lerp(weakLinkColor, other.weakLinkColor, t),
      weakTextColor: Color.lerp(weakTextColor, other.weakTextColor, t),
      weakTextColorPlus:
          Color.lerp(weakTextColorPlus, other.weakTextColorPlus, t),
      weakTextColorPlusPlus:
          Color.lerp(weakTextColorPlusPlus, other.weakTextColorPlusPlus, t),
      dialogDefaultTextColor:
          Color.lerp(dialogDefaultTextColor, other.dialogDefaultTextColor, t),
      dialogBackgroundColor:
          Color.lerp(dialogBackgroundColor, other.dialogBackgroundColor, t),
      columnBlockBorderColor:
          Color.lerp(columnBlockBorderColor, other.columnBlockBorderColor, t),
      columnBlockBackgroundColor: Color.lerp(
          columnBlockBackgroundColor, other.columnBlockBackgroundColor, t),
      columnBlockDividerColor:
          Color.lerp(columnBlockDividerColor, other.columnBlockDividerColor, t),
      textfieldHintColor:
          Color.lerp(textfieldHintColor, other.textfieldHintColor, t),
      textfieldHintDeepColor:
          Color.lerp(textfieldHintDeepColor, other.textfieldHintDeepColor, t),
      textfieldLabelColor:
          Color.lerp(textfieldLabelColor, other.textfieldLabelColor, t),
      textfieldValueColor:
          Color.lerp(textfieldValueColor, other.textfieldValueColor, t),
      textfieldBackgroundColor: Color.lerp(
          textfieldBackgroundColor, other.textfieldBackgroundColor, t),
      textfieldSelectorColor:
          Color.lerp(textfieldSelectorColor, other.textfieldSelectorColor, t),
      paymentItemBorderColor:
          Color.lerp(paymentItemBorderColor, other.paymentItemBorderColor, t),
      paymentItemBackgroundColor: Color.lerp(
          paymentItemBackgroundColor, other.paymentItemBackgroundColor, t),
      paymentItemTitleColor:
          Color.lerp(paymentItemTitleColor, other.paymentItemTitleColor, t),
      paymentItemPriceColor:
          Color.lerp(paymentItemPriceColor, other.paymentItemPriceColor, t),
      paymentItemDateColor:
          Color.lerp(paymentItemDateColor, other.paymentItemDateColor, t),
      paymentItemDescriptionColor: Color.lerp(
          paymentItemDescriptionColor, other.paymentItemDescriptionColor, t),
    );
  }

  static const light = CustomColors(
    borderRadius: 8,
    appBarBackgroundImage: 'assets/background.png',
    appBarBackgroundImageForRoom: 'assets/background-team.png',
    appBarBackgroundImageForCreativeIsland:
        'assets/background-creative-island.webp',
    appBarBackgroundImageDiscovery: 'assets/background-discovery.png',
    chatRoomBackground: Color.fromARGB(255, 239, 239, 239),
    chatRoomReplyBackground: Colors.white,
    chatRoomReplyBackgroundSecondary: Color.fromARGB(200, 255, 255, 255),
    chatRoomReplyText: Color(0xFF000000),
    chatRoomSenderBackground: Color.fromARGB(255, 133, 238, 94),
    chatRoomSenderBackgroundSecondary: Color.fromARGB(255, 133, 238, 94),
    chatRoomSenderBackgroundWarning: Color.fromARGB(255, 255, 176, 131),
    chatRoomSenderText: Color(0xFF000000),
    tagsBackground: Color.fromARGB(255, 238, 238, 238),
    tagsBackgroundHover: Color.fromARGB(255, 237, 237, 237),
    tagsText: Colors.black,
    chatInputPanelBackground: Color.fromARGB(255, 250, 250, 250),
    chatInputPanelText: Color.fromARGB(255, 151, 151, 151),
    chatInputAreaBackground: Color.fromARGB(255, 244, 244, 244),
    chatExampleItemBackground: Color.fromARGB(194, 221, 221, 221),
    chatExampleItemBackgroundHover: Color.fromARGB(255, 223, 223, 223),
    chatExampleItemText: Color.fromARGB(255, 66, 66, 66),
    chatExampleTitleText: Color.fromARGB(255, 66, 66, 66),
    markdownLinkColor: Colors.blue,
    markdownPreColor: Color.fromARGB(134, 224, 224, 224),
    markdownCodeColor: Color.fromARGB(255, 244, 54, 111),
    boxShadowColor: Color.fromARGB(149, 232, 232, 232),
    backgroundColor: Colors.white,
    backgroundInvertedColor: Color.fromARGB(255, 72, 72, 72),
    backgroundContainerColor: Color.fromARGB(255, 234, 234, 234),
    textFieldBorderColor: Color.fromARGB(255, 228, 228, 228),
    iconButtonColor: Color.fromARGB(255, 117, 117, 117),
    linkColor: Color.fromARGB(255, 9, 185, 85),
    weakLinkColor: Color.fromARGB(255, 117, 117, 117),
    weakTextColor: Color.fromARGB(255, 117, 117, 117),
    weakTextColorPlus: Color.fromARGB(255, 146, 146, 146),
    weakTextColorPlusPlus: Color.fromARGB(255, 29, 29, 29),
    dialogDefaultTextColor: Color.fromARGB(195, 0, 0, 0),
    dialogBackgroundColor: Colors.white,
    columnBlockBorderColor: Color.fromARGB(255, 236, 236, 236),
    columnBlockBackgroundColor: Color.fromARGB(255, 255, 255, 255),
    columnBlockDividerColor: Color.fromARGB(255, 241, 241, 241),
    textfieldHintColor: Color.fromARGB(255, 227, 227, 227),
    textfieldHintDeepColor: Color.fromARGB(255, 94, 94, 94),
    textfieldLabelColor: Color.fromARGB(255, 66, 66, 66),
    textfieldValueColor: Color.fromARGB(255, 108, 108, 108),
    textfieldBackgroundColor: Color.fromARGB(255, 244, 244, 244),
    textfieldSelectorColor: Color.fromARGB(255, 9, 185, 85),
    paymentItemBorderColor: Color.fromARGB(255, 228, 228, 228),
    paymentItemBackgroundColor: Color.fromARGB(255, 245, 245, 245),
    paymentItemTitleColor: Color.fromARGB(255, 66, 66, 66),
    paymentItemPriceColor: Color.fromARGB(255, 66, 66, 66),
    paymentItemDateColor: Color.fromARGB(255, 117, 117, 117),
    paymentItemDescriptionColor: Color.fromARGB(255, 117, 117, 117),
  );

  static const dark = CustomColors(
    borderRadius: 8,
    appBarBackgroundImage: 'assets/background-dark.png',
    appBarBackgroundImageForRoom: 'assets/background-team-dark.png',
    appBarBackgroundImageForCreativeIsland:
        'assets/background-creative-island-dark.webp',
    appBarBackgroundImageDiscovery: 'assets/background-discovery-dark.webp',
    chatRoomBackground: Color.fromARGB(255, 53, 53, 53),
    chatRoomReplyBackground: Color.fromARGB(255, 22, 22, 22),
    chatRoomReplyBackgroundSecondary: Color.fromARGB(200, 39, 39, 39),
    chatRoomReplyText: Color(0xFFECEFF1),
    chatRoomSenderBackground: Color.fromARGB(255, 36, 172, 86),
    chatRoomSenderBackgroundSecondary: Color.fromARGB(181, 36, 172, 86),
    chatRoomSenderBackgroundWarning: Color.fromARGB(255, 255, 176, 131),
    chatRoomSenderText: Color(0xFFECEFF1),
    tagsBackground: Color.fromARGB(255, 69, 69, 69),
    tagsBackgroundHover: Color.fromARGB(255, 106, 106, 106),
    tagsText: Color.fromARGB(255, 218, 218, 218),
    chatInputPanelBackground: Color.fromARGB(255, 48, 48, 48),
    chatInputPanelText: Color.fromARGB(255, 187, 187, 187),
    chatInputAreaBackground: Color.fromARGB(255, 88, 88, 88),
    chatExampleItemBackground: Color.fromARGB(255, 80, 80, 80),
    chatExampleItemBackgroundHover: Color.fromARGB(255, 69, 69, 69),
    chatExampleItemText: Color.fromARGB(255, 218, 218, 218),
    chatExampleTitleText: Color.fromARGB(255, 150, 150, 150),
    markdownLinkColor: Color.fromARGB(255, 0, 122, 255),
    markdownPreColor: Color.fromARGB(255, 69, 69, 69),
    markdownCodeColor: Color.fromARGB(255, 244, 54, 111),
    boxShadowColor: Color.fromARGB(70, 37, 37, 37),
    backgroundColor: Color.fromARGB(255, 48, 48, 48),
    backgroundInvertedColor: Color.fromARGB(255, 233, 233, 233),
    backgroundContainerColor: Color.fromARGB(255, 41, 41, 41),
    textFieldBorderColor: Color.fromARGB(106, 107, 107, 107),
    iconButtonColor: Color.fromARGB(255, 218, 218, 218),
    linkColor: Color.fromARGB(255, 9, 185, 85),
    weakLinkColor: Color.fromARGB(255, 218, 218, 218),
    weakTextColor: Color.fromARGB(255, 130, 130, 130),
    weakTextColorPlus: Color.fromARGB(255, 137, 137, 137),
    weakTextColorPlusPlus: Color.fromARGB(255, 173, 173, 173),
    dialogDefaultTextColor: Color.fromARGB(195, 255, 255, 255),
    dialogBackgroundColor: Color.fromARGB(255, 48, 48, 48),
    columnBlockBorderColor: Color.fromARGB(255, 72, 72, 72),
    columnBlockBackgroundColor: Color.fromARGB(255, 52, 52, 52),
    columnBlockDividerColor: Color.fromARGB(160, 60, 60, 60),
    textfieldHintColor: Color.fromARGB(255, 105, 105, 105),
    textfieldHintDeepColor: Color.fromARGB(255, 170, 170, 170),
    textfieldLabelColor: Color.fromARGB(255, 218, 218, 218),
    textfieldValueColor: Color.fromARGB(255, 207, 207, 207),
    textfieldBackgroundColor: Color.fromARGB(255, 88, 88, 88),
    textfieldSelectorColor: Color.fromARGB(255, 9, 185, 85),
    paymentItemBorderColor: Color.fromARGB(255, 69, 69, 69),
    paymentItemBackgroundColor: Color.fromARGB(255, 29, 29, 29),
    paymentItemTitleColor: Color.fromARGB(255, 218, 218, 218),
    paymentItemPriceColor: Color.fromARGB(255, 218, 218, 218),
    paymentItemDateColor: Color.fromARGB(255, 218, 218, 218),
    paymentItemDescriptionColor: Color.fromARGB(255, 218, 218, 218),
  );

  @override
  ThemeExtension<CustomColors> copyWith({
    double? borderRadius,
    String? appBarBackgroundImage,
    String? appBarBackgroundImageForRoom,
    String? appBarBackgroundImageForCreativeIsland,
    String? appBarBackgroundImageDiscovery,
    Color? chatRoomBackground,
    Color? chatRoomReplyBackground,
    Color? chatRoomReplyBackgroundSecondary,
    Color? chatRoomReplyText,
    Color? chatRoomSenderBackground,
    Color? chatRoomSenderBackgroundSecondary,
    Color? chatRoomSenderBackgroundWarning,
    Color? chatRoomSenderText,
    Color? tagsBackground,
    Color? tagsBackgroundHover,
    Color? tagsText,
    Color? chatInputPanelBackground,
    Color? chatInputPanelText,
    Color? chatInputAreaBackground,
    Color? chatExampleItemBackground,
    Color? chatExampleItemBackgroundHover,
    Color? chatExampleItemText,
    Color? chatExampleTitleText,
    Color? markdownLinkColor,
    Color? markdownPreColor,
    Color? markdownCodeColor,
    Color? boxShadowColor,
    Color? backgroundColor,
    Color? backgroundInvertedColor,
    Color? backgroundContainerColor,
    Color? textFieldBorderColor,
    Color? iconButtonColor,
    Color? linkColor,
    Color? weakLinkColor,
    Color? weakTextColor,
    Color? weakTextColorPlus,
    Color? weakTextColorPlusPlus,
    Color? dialogDefaultTextColor,
    Color? dialogBackgroundColor,
    Color? columnBlockBorderColor,
    Color? columnBlockBackgroundColor,
    Color? columnBlockDividerColor,
    Color? textfieldHintColor,
    Color? textfieldHintDeepColor,
    Color? textfieldLabelColor,
    Color? textfieldValueColor,
    Color? textfieldBackgroundColor,
    Color? textfieldSelectorColor,
    Color? paymentItemBorderColor,
    Color? paymentItemBackgroundColor,
    Color? paymentItemTitleColor,
    Color? paymentItemPriceColor,
    Color? paymentItemDateColor,
    Color? paymentItemDescriptionColor,
  }) {
    return CustomColors(
      borderRadius: borderRadius ?? this.borderRadius,
      appBarBackgroundImage:
          appBarBackgroundImage ?? this.appBarBackgroundImage,
      appBarBackgroundImageForRoom:
          appBarBackgroundImageForRoom ?? this.appBarBackgroundImageForRoom,
      appBarBackgroundImageForCreativeIsland:
          appBarBackgroundImageForCreativeIsland ??
              this.appBarBackgroundImageForCreativeIsland,
      appBarBackgroundImageDiscovery:
          appBarBackgroundImageDiscovery ?? this.appBarBackgroundImageDiscovery,
      chatRoomBackground: chatRoomBackground ?? this.chatRoomBackground,
      chatRoomReplyBackground:
          chatRoomReplyBackground ?? this.chatRoomReplyBackground,
      chatRoomReplyBackgroundSecondary: chatRoomReplyBackgroundSecondary ??
          this.chatRoomReplyBackgroundSecondary,
      chatRoomReplyText: chatRoomReplyText ?? this.chatRoomReplyText,
      chatRoomSenderBackground:
          chatRoomSenderBackground ?? this.chatRoomSenderBackground,
      chatRoomSenderBackgroundSecondary: chatRoomSenderBackgroundSecondary ??
          this.chatRoomSenderBackgroundSecondary,
      chatRoomSenderBackgroundWarning: chatRoomSenderBackgroundWarning ??
          this.chatRoomSenderBackgroundWarning,
      chatRoomSenderText: chatRoomSenderText ?? this.chatRoomSenderText,
      tagsBackground: tagsBackground ?? this.tagsBackground,
      tagsBackgroundHover: tagsBackgroundHover ?? this.tagsBackgroundHover,
      tagsText: tagsText ?? this.tagsText,
      chatInputPanelBackground:
          chatInputPanelBackground ?? this.chatInputPanelBackground,
      chatInputPanelText: chatInputPanelText ?? this.chatInputPanelText,
      chatInputAreaBackground:
          chatInputAreaBackground ?? this.chatInputAreaBackground,
      chatExampleItemBackground:
          chatExampleItemBackground ?? this.chatExampleItemBackground,
      chatExampleItemBackgroundHover:
          chatExampleItemBackgroundHover ?? this.chatExampleItemBackgroundHover,
      chatExampleItemText: chatExampleItemText ?? this.chatExampleItemText,
      chatExampleTitleText: chatExampleTitleText ?? this.chatExampleTitleText,
      markdownLinkColor: markdownLinkColor ?? this.markdownLinkColor,
      markdownPreColor: markdownPreColor ?? this.markdownPreColor,
      markdownCodeColor: markdownCodeColor ?? this.markdownCodeColor,
      boxShadowColor: boxShadowColor ?? this.boxShadowColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundInvertedColor:
          backgroundInvertedColor ?? this.backgroundInvertedColor,
      backgroundContainerColor:
          backgroundContainerColor ?? this.backgroundContainerColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      iconButtonColor: iconButtonColor ?? this.iconButtonColor,
      linkColor: linkColor ?? this.linkColor,
      weakLinkColor: weakLinkColor ?? this.weakLinkColor,
      weakTextColor: weakTextColor ?? this.weakTextColor,
      weakTextColorPlus: weakTextColorPlus ?? this.weakTextColorPlus,
      weakTextColorPlusPlus:
          weakTextColorPlusPlus ?? this.weakTextColorPlusPlus,
      dialogDefaultTextColor:
          dialogDefaultTextColor ?? this.dialogDefaultTextColor,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      columnBlockBorderColor:
          columnBlockBorderColor ?? this.columnBlockBorderColor,
      columnBlockBackgroundColor:
          columnBlockBackgroundColor ?? this.columnBlockBackgroundColor,
      columnBlockDividerColor:
          columnBlockDividerColor ?? this.columnBlockDividerColor,
      textfieldHintColor: textfieldHintColor ?? this.textfieldHintColor,
      textfieldHintDeepColor:
          textfieldHintDeepColor ?? this.textfieldHintDeepColor,
      textfieldLabelColor: textfieldLabelColor ?? this.textfieldLabelColor,
      textfieldValueColor: textfieldValueColor ?? this.textfieldValueColor,
      textfieldBackgroundColor:
          textfieldBackgroundColor ?? this.textfieldBackgroundColor,
      textfieldSelectorColor:
          textfieldSelectorColor ?? this.textfieldSelectorColor,
      paymentItemBorderColor:
          paymentItemBorderColor ?? this.paymentItemBorderColor,
      paymentItemBackgroundColor:
          paymentItemBackgroundColor ?? this.paymentItemBackgroundColor,
      paymentItemTitleColor:
          paymentItemTitleColor ?? this.paymentItemTitleColor,
      paymentItemPriceColor:
          paymentItemPriceColor ?? this.paymentItemPriceColor,
      paymentItemDateColor: paymentItemDateColor ?? this.paymentItemDateColor,
      paymentItemDescriptionColor:
          paymentItemDescriptionColor ?? this.paymentItemDescriptionColor,
    );
  }
}
