import 'dart:typed_data';

import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/background_container.dart';
import 'package:askaide/page/component/loading.dart';
import 'package:askaide/page/component/sliver_component.dart';
import 'package:askaide/page/creative_island/gallery/components/image_card.dart';
import 'package:askaide/page/creative_island/gallery/data/gallery_datasource.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api/creative.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';

import '../change_outfit/logic.dart';
import '../component/column_block.dart';
import '../component/dialog.dart';
import '../component/enhanced_button.dart';
import '../creative_island/draw/components/change_outfits/provider.dart';
import '../creative_island/draw/components/image_selector.dart';
import '../creative_island/draw/components/image_selector_crop.dart';

class ChangeOutfits extends StatefulWidget {
  final SettingRepository setting;

  const ChangeOutfits({super.key, required this.setting});

  @override
  State<ChangeOutfits> createState() => _ChangeOutfitsState();
}

class _ChangeOutfitsState extends State<ChangeOutfits> {
  String? selectedImagePath;
  String? selectedImagePathCloths;
  Uint8List? selectedImageData;
  Uint8List? selectedImageDataCloths;
  final logic = Get.put(Change_outfitLogic());

  // final GalleryDatasource datasource = GalleryDatasource();
  @override
  void initState() {
    super.initState();
    // Provider.of<ChangeOutfitsProvider>(context, listen: false).getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GetBuilder<Change_outfitLogic>(
          builder: (logic) {
            return _buildIslandItems(customColors);
          },
        ),
      ),
    );
  }

  /// 创作岛列表
  Widget _buildIslandItems(CustomColors customColors) {
    return SliverComponent(
      title: Text(
        "AI换装",
        style: TextStyle(
          fontSize: CustomSize.appBarTitleSize,
          color: customColors.backgroundInvertedColor,
        ),
      ),
      backgroundImage: Image.asset(
        customColors.appBarBackgroundImageDiscovery!,
        fit: BoxFit.cover,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        ColumnBlock(
        innerPanding: 10,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        children: [
          // 上传图片
          ImageSelectorCrop(
            clothList: logic.modelList,
            onImageSelected: ({path, data}) {
              logic.clearModelSelect();
              if (path != null) {
                setState(() {
                  selectedImagePath = path;
                  selectedImageData = null;
                });
              }

              if (data != null) {
                setState(() {
                  selectedImageData = data;
                  selectedImagePath = null;
                });
              }
            },
            selectedImagePath: selectedImagePath,
            selectedImageData: selectedImageData,
            title: "上传参考图",
            height: 170,
            titleHelper: InkWell(
              onTap: () {
                showBeautyDialog(
                  context,
                  type: QuickAlertType.info,
                  text: "上传照片",
                  confirmBtnText: AppLocale.gotIt.getString(context),
                  showCancelBtn: false,
                );
              },
              child: Icon(
                Icons.help_outline,
                size: 16,
                color: customColors.weakLinkColor?.withAlpha(150),
              ),
            ),
            selectedIndex: ({index}) {
              setState(() {
                selectedImagePath = null;
                selectedImageData = null;
              });
              logic.selectModels(index!);
            },
          )
        ],
      ),
          ColumnBlock(
            innerPanding: 10,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            children: [
              // 上传图片
              ImageSelectorCrop(
                selectedIndex: ({index}) {
                  setState(() {
                    selectedImagePathCloths = null;
                    selectedImageDataCloths = null;
                  });
                  logic.selectCloth(index!);
                },
                onImageSelected: ({path, data}) {
                  logic.clearClothSelect();
                  if (path != null) {
                    setState(() {
                      selectedImagePathCloths = path;
                      selectedImageDataCloths = null;
                    });
                  }
                  if (data != null) {
                    setState(() {
                      selectedImageDataCloths = data;
                      selectedImagePathCloths = null;
                    });
                  }
                },
                clothList: logic.clothList,
                selectedImagePath: selectedImagePathCloths,
                selectedImageData: selectedImageDataCloths,
                title: "上传上衣",
                height: 170,
                titleHelper: InkWell(
                  onTap: () {
                    logic.getData();
                    showBeautyDialog(
                      context,
                      type: QuickAlertType.info,
                      text: "上传照片",
                      confirmBtnText: AppLocale.gotIt.getString(context),
                      showCancelBtn: false,
                    );
                  },
                  child: Icon(
                    Icons.help_outline,
                    size: 16,
                    color: customColors.weakLinkColor?.withAlpha(150),
                  ),
                ),
              )
            ],
          ),


          Padding(padding: const EdgeInsets.all(5),child: EnhancedButton(
            title: AppLocale.generate.getString(context),
            onPressed: (){},
          ),)
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          //   child: Text('热门作品'),
          // ),
        ],
      ),
    );
  }

  int _calCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > CustomSize.maxWindowSize) {
      width = CustomSize.maxWindowSize;
    }
    return (width / 220).round();
  }

  double _calImageSelectorHeight(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width > CustomSize.smallWindowSize) {
      width = CustomSize.smallWindowSize;
    }

    return width - 15 * 2 - 10 * 2 - 10;
  }
}
