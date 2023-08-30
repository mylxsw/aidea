import 'package:flutter/material.dart';

class AttachedButtonPanel extends StatelessWidget {
  final List<TextButton> buttons;

  const AttachedButtonPanel({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    final columns = <Widget>[];
    final itemPerRow = buttons.length > 4 ? 3 : 4;
    for (var i = 0; i < buttons.length; i += itemPerRow) {
      final row = <Widget>[];
      for (var j = 0; j < itemPerRow; j++) {
        if (i + j < buttons.length) {
          row.add(buttons[i + j]);
        }
      }
      if (i > 0) {
        columns.add(const SizedBox(height: 10));
      }
      columns.add(Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: row,
      ));
    }
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color.fromARGB(223, 0, 0, 0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns,
        ),
      ),
    );
  }
}
