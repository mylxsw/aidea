import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/image.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/weak_text_button.dart';
import 'package:askaide/page/dialog.dart';
import 'package:askaide/page/theme/custom_theme.dart';
import 'package:askaide/repo/api/room_gallery.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoomCard extends StatelessWidget {
  final bool selected;
  final RoomGallery item;
  final Function(RoomGallery) onItemSelected;
  final Function()? selectedCheck;
  final double fontsize;
  final bool stopAllEvents;
  const RoomCard({
    super.key,
    this.selected = false,
    required this.item,
    required this.onItemSelected,
    this.fontsize = 13,
    this.selectedCheck,
    this.stopAllEvents = false,
  });

  Future openRoomCard(BuildContext context, RoomGallery item) {
    return openModalBottomSheet(
      context,
      (_) {
        return Container(
          padding: const EdgeInsets.only(top: 20),
          child: GalleryRoomCard(
            item: item,
            selected: selected,
            // onConfirm: () {
            //   onItemSelected(item);
            // },
          ),
        );
      },
      heightFactor: 0.7,
      disableCompleteEvent: true,
      disableEvent: stopAllEvents,
    );
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return InkWell(
      onLongPress: () async {
        await openRoomCard(context, item);
        selectedCheck?.call();
      },
      onTap: () {
        onItemSelected(item);
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: selected
                  ? Border.all(
                      width: 2,
                      color: customColors.linkColor ?? Colors.green,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImageEnhanced(
                    imageUrl: imageURL(item.avatarUrl, qiniuImageTypeAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
                if (selected)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: customColors.linkColor ?? Colors.green,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: customColors.weakTextColorPlusPlus,
              fontSize: fontsize,
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryRoomCard extends StatelessWidget {
  final RoomGallery item;
  final Function()? onConfirm;
  final bool selected;
  const GalleryRoomCard(
      {super.key, required this.item, this.onConfirm, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  height: MediaQuery.of(context).size.width - 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImageEnhanced(
                      imageUrl: item.avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.description != '')
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '简介：',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (onConfirm != null)
          Container(
            height: 70,
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Row(
              children: [
                WeakTextButton(
                  title: '取消',
                  onPressed: () {
                    context.pop();
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: EnhancedButton(
                      title: selected ? '移除' : '选择',
                      onPressed: () {
                        onConfirm!();
                        context.pop();
                      }),
                )
              ],
            ),
          )
      ],
    );
  }
}
