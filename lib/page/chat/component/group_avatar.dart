import 'package:askaide/helper/image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GroupAvatar extends StatelessWidget {
  final double size;
  final double padding;
  final double margin;
  final List<String> avatars;
  final Color? backgroundColor;

  var row = 0, column = 0;

  GroupAvatar({
    super.key,
    this.size = 40,
    this.padding = 2,
    this.margin = 3,
    required this.avatars,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = buildAvatar(context);

    return Container(
      padding: const EdgeInsets.all(4),
      width: size,
      height: size,
      color: backgroundColor ?? Colors.grey.withAlpha(100),
      child: avatar,
    );
  }

  double get innerSize => size - 8;

  Widget buildAvatar(BuildContext context) {
    var childCount = avatars.length;
    int columnMax;
    List<Widget> icons = [];
    List<Widget> stacks = [];
    // 五张图片之后（包含5张），每行的最大列数是3
    double imgWidth;

    if (childCount < 2) {
      return Container(
        width: innerSize,
        height: innerSize,
        color: Colors.transparent,
      );
    }

    if (childCount >= 5) {
      columnMax = 3;
      imgWidth = (innerSize - (padding * columnMax) - margin) / columnMax;
    } else {
      columnMax = 2;
      imgWidth = (innerSize - (padding * columnMax) - margin) / columnMax;
    }
    for (var i = 0; i < childCount; i++) {
      icons.add(_weChatGroupChatChildIcon(avatars[i], imgWidth));
    }
    row = 0;
    column = 0;
    var centerTop = 0.0;
    if (childCount == 2 || childCount == 5 || childCount == 6) {
      centerTop = imgWidth / 2;
    }
    for (var i = 0; i < childCount; i++) {
      var left = imgWidth * row + padding * (row + 1);
      var top = imgWidth * column + margin * column + centerTop;
      switch (childCount) {
        case 3:
        case 7:
          _topOneIcon(stacks, icons[i], childCount, i, imgWidth, left, top);
          break;
        case 5:
        case 8:
          _topTwoIcon(stacks, icons[i], childCount, i, imgWidth, left, top);
          break;
        default:
          _otherIcon(
              stacks, icons[i], childCount, i, imgWidth, left, top, columnMax);
          break;
      }
    }

    return Container(
      width: innerSize,
      height: innerSize,
      color: Colors.transparent,
      padding: EdgeInsets.only(top: padding),
      alignment: AlignmentDirectional.bottomCenter,
      child: Stack(
        children: stacks,
      ),
    );
  }

  _weChatGroupChatChildIcon(String avatar, double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: CachedNetworkImage(
        imageUrl: imageURL(avatar, 'avatar'),
        height: width,
        width: width,
        fit: BoxFit.fill,
      ),
    );
  }

  // 顶部为一张图片
  _topOneIcon(List<Widget> stacks, Widget child, int childCount, i, imgWidth,
      left, top) {
    if (i == 0) {
      var firstLeft = imgWidth / 2 + left + margin / 2;
      if (childCount == 7) {
        firstLeft = imgWidth + left + margin;
      }
      stacks.add(Positioned(
        left: firstLeft,
        child: child,
      ));
      row = 0;
      // 换行
      column++;
    } else {
      stacks.add(Positioned(
        left: left,
        top: top,
        child: child,
      ));
      // 换列
      row++;
      if (i == 3) {
        // 第一例
        row = 0;
        // 换行
        column++;
      }
    }
  }

// 顶部为两张图片
  _topTwoIcon(List<Widget> stacks, Widget child, int childCount, i, imgWidth,
      left, top) {
    if (i == 0 || i == 1) {
      stacks.add(Positioned(
        left: imgWidth / 2 + left + margin / 2,
        top: childCount == 5 ? top : 0.0,
        child: child,
      ));
      row++;
      if (i == 1) {
        row = 0;
        // 换行
        column++;
      }
    } else {
      stacks.add(Positioned(
        left: left,
        top: top,
        child: child,
      ));
      // 换列
      row++;
      if (i == 4) {
        // 第一例
        row = 0;
        // 换行
        column++;
      }
    }
  }

  _otherIcon(List<Widget> stacks, Widget child, int childCount, i, imgWidth,
      left, top, columnMax) {
    stacks.add(Positioned(
      left: left,
      top: top,
      child: child,
    ));
    // 换列
    row++;
    if ((i + 1) % columnMax == 0) {
      // 第一例
      row = 0;
      // 换行
      column++;
    }
  }
}
