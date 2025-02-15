import 'dart:io';
import 'dart:typed_data';

import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/logger.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/column_block.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/creative_island/draw/components/image_selector.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DrawboardScreen extends StatefulWidget {
  const DrawboardScreen({super.key});

  @override
  State<DrawboardScreen> createState() => _DrawboardScreenState();
}

class _DrawboardScreenState extends State<DrawboardScreen> {
  final DrawMaskBoardController controller = DrawMaskBoardController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画板'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ColumnBlock(
          children: [
            ImageSelector(
              onImageSelected: ({path, data}) {
                if (path == null || path.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        actions: [
                          IconButton(
                            onPressed: () async {
                              final imageData = await controller.save();

                              if (imageData == null) {
                                // ignore: use_build_context_synchronously
                                showErrorMessageEnhanced(context, '获取图片数据失败');
                                return;
                              }

                              // save imageData to file
                              if (PlatformTool.isIOS() || PlatformTool.isAndroid()) {
                                await ImageGallerySaver.saveImage(
                                  imageData.buffer.asUint8List(),
                                  quality: 100,
                                );

                                showSuccessMessage(AppLocale.operateSuccess.getString(context));
                              } else {
                                if (PlatformTool.isWindows()) {
                                  FileSaver.instance
                                      .saveAs(
                                    name: randomId(),
                                    ext: '.png',
                                    bytes: imageData.buffer.asUint8List(),
                                    mimeType: MimeType.png,
                                  )
                                      .then((value) async {
                                    if (value == null) {
                                      return;
                                    }

                                    await File(value).writeAsBytes(imageData.buffer.asUint8List());

                                    Logger.instance.d('File saved successfully: $value');
                                    showSuccessMessage(AppLocale.operateSuccess.getString(context));
                                  });
                                } else {
                                  FileSaver.instance
                                      .saveFile(
                                    name: randomId(),
                                    ext: 'png',
                                    bytes: imageData.buffer.asUint8List(),
                                    mimeType: MimeType.png,
                                  )
                                      .then((value) {
                                    showSuccessMessage(AppLocale.operateSuccess.getString(context));
                                  });
                                }
                              }
                            },
                            icon: const Icon(Icons.save),
                          ),
                        ],
                      ),
                      body: DrawMaskBoard(
                        backgroundImage: File(path),
                        controller: controller,
                      ),
                    ),
                  ),
                );
              },
              title: AppLocale.referenceImage.getString(context),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawMaskBoardController {
  DrawingController? controller;
  Future<ByteData?> Function()? onSave;

  init({
    DrawingController? controller,
    Future<ByteData?> Function()? onSave,
  }) {
    this.controller = controller;
    this.onSave = onSave;
  }

  Future<ByteData?> save() {
    if (onSave == null) return Future.value(null);
    return onSave!();
  }

  unsetController() {
    controller = null;
    onSave = null;
  }
}

class DrawMaskBoard extends StatefulWidget {
  final File backgroundImage;
  final DrawMaskBoardController controller;
  const DrawMaskBoard({
    super.key,
    required this.backgroundImage,
    required this.controller,
  });

  @override
  State<DrawMaskBoard> createState() => _DrawMaskBoardState();
}

class _DrawMaskBoardState extends State<DrawMaskBoard> {
  final DrawingController _controller = DrawingController();

  bool showBackground = true;
  double strokeWidth = 10;
  String selectedToolbar = 'draw';

  @override
  void dispose() {
    widget.controller.unsetController();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.init(
        controller: _controller,
        onSave: () async {
          setState(() {
            showBackground = false;
          });

          await Future.delayed(const Duration(milliseconds: 100));

          try {
            return _controller.getImageData();
          } finally {
            setState(() {
              showBackground = true;
            });
          }
        });

    _controller.setStyle(color: Colors.white, strokeWidth: strokeWidth);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _controller.setPaintContent = SimpleLine();
                    setState(() {
                      selectedToolbar = 'draw';
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: selectedToolbar == 'draw' ? customColors.linkColor : customColors.weakLinkColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _controller.setPaintContent = Eraser();
                    setState(() {
                      selectedToolbar = 'eraser';
                    });
                  },
                  icon: Icon(
                    CupertinoIcons.bandage,
                    color: selectedToolbar == 'eraser' ? customColors.linkColor : customColors.weakLinkColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.undo,
                    color: customColors.weakLinkColor,
                  ),
                  onPressed: () {
                    _controller.undo();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.redo,
                    color: customColors.weakLinkColor,
                  ),
                  onPressed: () {
                    _controller.redo();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: customColors.weakLinkColor,
                  ),
                  onPressed: () {
                    _controller.clear();
                  },
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    '画笔粗细',
                    style: TextStyle(
                      fontSize: 12,
                      color: customColors.weakTextColor,
                    ),
                  ),
                  Expanded(
                    child: Transform.scale(
                      scale: 0.8,
                      child: Slider(
                        value: strokeWidth,
                        min: 1,
                        max: 100,
                        activeColor: customColors.weakLinkColor,
                        onChanged: (value) {
                          setState(() {
                            strokeWidth = value;
                            _controller.setStyle(strokeWidth: strokeWidth);
                          });
                        },
                      ),
                    ),
                  ),
                  Text(
                    '${strokeWidth.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: customColors.weakTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder(
            future: decodeImageFromList(widget.backgroundImage.readAsBytesSync()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return DrawingBoard(
                controller: _controller,
                background: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width /
                      snapshot.data!.width.toDouble() *
                      snapshot.data!.height.toDouble(),
                  color: Colors.black,
                  child: showBackground ? Image.file(widget.backgroundImage, fit: BoxFit.fitWidth) : null,
                ),
                showDefaultActions: false,
              );
            },
          ),
        ),
      ],
    );
  }
}
