import 'package:askaide/page/component/random_avatar.dart';
import 'package:flutter/material.dart';

class AvatarSelectorScreen extends StatefulWidget {
  final AvatarUsage usage;
  const AvatarSelectorScreen({super.key, required this.usage});

  @override
  State<AvatarSelectorScreen> createState() => _AvatarSelectorScreenState();
}

class _AvatarSelectorScreenState extends State<AvatarSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择头像'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        padding: const EdgeInsets.all(8),
        children: List.generate(500, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RandomAvatar(id: 500 + index, size: 60, usage: widget.usage),
              const SizedBox(height: 8),
              Text('${500 + index}'),
            ],
          );
        }),
      ),
    );
  }
}
