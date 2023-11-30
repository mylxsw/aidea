import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/enhanced_input.dart';
import 'package:askaide/page/component/image.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ArtisticStyleSelector extends StatelessWidget {
  final List<CreativeIslandArtisticStyle> styles;
  final Function(CreativeIslandArtisticStyle style) onSelected;
  final CreativeIslandArtisticStyle? selectedStyle;

  const ArtisticStyleSelector({
    super.key,
    required this.styles,
    required this.onSelected,
    this.selectedStyle,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return EnhancedInput(
      title: Text(
        AppLocale.style.getString(context),
        style: TextStyle(
          color: customColors.textfieldLabelColor,
          fontSize: 16,
        ),
      ),
      value: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(selectedStyle == null || selectedStyle!.name == ''
          //     ? AppLocale.auto.getString(context)
          //     : selectedStyle!.name),
          // const SizedBox(width: 10),
          _buildImageStyleItemPreview(
            customColors,
            selectedStyle == null
                ? CreativeIslandArtisticStyle(
                    id: '', name: '', previewImage: '')
                : selectedStyle!,
            size: 50,
          ),
        ],
      ),
      onPressed: () {
        openModalBottomSheet(
          context,
          (context) {
            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              children: [
                for (var item in [
                  CreativeIslandArtisticStyle(
                      id: '', name: '自动', previewImage: ''),
                  ...styles
                ])
                  InkWell(
                    onTap: () {
                      onSelected(item);

                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _buildImageStyleItemPreview(
                              customColors,
                              item,
                              showSelected: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
          heightFactor: 0.8,
        );
      },
    );
  }

  Widget _buildImageStyleItemPreview(
    CustomColors customColors,
    CreativeIslandArtisticStyle style, {
    double? size,
    bool showSelected = false,
  }) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: showSelected &&
                  (selectedStyle != null && style.id == selectedStyle!.id)
              ? Border.all(
                  color: customColors.linkColor ?? Colors.green,
                  width: 1,
                )
              : null,
          image: style.previewImage != null && style.previewImage != ''
              ? DecorationImage(
                  image:
                      CachedNetworkImageProviderEnhanced(style.previewImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: style.previewImage == ''
            ? const Center(
                child: Icon(
                  Icons.interests,
                  color: Colors.grey,
                  size: 40,
                ),
              )
            : null);
  }
}
