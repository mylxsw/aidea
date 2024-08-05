import 'dart:convert';

import 'package:dart_openai/openai.dart';

class ChatMessage extends OpenAIChatCompletionChoiceMessageModel {
  final List<String>? images;
  final String? file;
  ChatMessage(
      {required super.role, required super.content, this.images, this.file});

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> res = {
      "role": role.name,
      "content": content,
    };

    if (file != null || (images != null && images!.isNotEmpty)) {
      final multipartContent = <dynamic>[];

      if (file != null) {
        try {
          multipartContent.add({
            'type': 'file',
            'file': jsonDecode(file!),
          });
        } catch (ignore) {
          // ignore
        }
      }

      if (images != null && images!.isNotEmpty) {
        multipartContent.addAll(images
                ?.map((e) => {
                      'type': 'image_url',
                      'image_url': {'url': e}
                    })
                .toList() ??
            []);
      }

      multipartContent.add({
        'type': 'text',
        'text': content,
      });

      res['multipart_content'] = multipartContent;
    }

    return res;
  }
}
