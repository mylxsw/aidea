import 'package:dart_openai/openai.dart';

class ChatMessage extends OpenAIChatCompletionChoiceMessageModel {
  final List<String>? images;
  ChatMessage({required super.role, required super.content, this.images});

  @override
  Map<String, dynamic> toMap() {
    if (images == null || images!.isEmpty) {
      return {
        "role": role.name,
        "content": content,
      };
    }

    return {
      "role": role.name,
      "content": content,
      "multipart_content": [
        ...(images
                ?.map((e) => {
                      'type': 'image_url',
                      'image_url': {'url': e}
                    })
                .toList() ??
            []),
        {
          'type': 'text',
          'text': content,
        },
      ],
    };
  }
}
