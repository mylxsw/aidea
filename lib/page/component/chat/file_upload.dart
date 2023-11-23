import 'dart:convert';

import 'package:askaide/page/component/image_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

class FileUpload {
  final PlatformFile file;
  String? url;

  FileUpload({required this.file, this.url});

  bool get uploaded => url != null;

  setUrl(String url) {
    this.url = url;
  }
}

class FileUploadPreview extends StatelessWidget {
  final List<String> images;
  const FileUploadPreview({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final children = images
        .map((e) {
          if (e.startsWith('http://') || e.startsWith('https://')) {
            return NetworkImagePreviewer(
              url: e,
              hidePreviewButton: true,
            );
          }

          if (e.startsWith('data:')) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.memory(
                const Base64Decoder().convert(e.split(',')[1]),
                fit: BoxFit.cover,
              ),
            );
          }
          return const SizedBox();
        })
        .map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 5),
              child: e,
            ))
        .toList();
    if (children.length > 1) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        children: children,
      );
    }

    return ListView(
      shrinkWrap: true,
      children: children,
    );
  }
}
