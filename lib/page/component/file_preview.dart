import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FilePreview extends StatelessWidget {
  final String? filename;
  final String? fileUrl;
  final String fileType;
  final double maxWidth;
  final MainAxisAlignment mainAxisAlignment;

  const FilePreview({
    super.key,
    this.filename,
    this.fileUrl,
    this.maxWidth = 300,
    this.mainAxisAlignment = MainAxisAlignment.start,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    var iconFilePath = 'assets/icons/file.png';
    switch (fileType) {
      case 'pdf':
        iconFilePath = 'assets/icons/pdf.png';
        break;
      case 'docx':
        iconFilePath = 'assets/icons/doc.png';
        break;
      case 'txt':
        iconFilePath = 'assets/icons/txt.png';
        break;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: 25,
      ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconFilePath,
            width: 20,
            height: 20,
          ),
          if (filename != null && filename != '') ...[
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                filename!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
