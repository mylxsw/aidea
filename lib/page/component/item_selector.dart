import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class ItemSelector extends StatelessWidget {
  final List<String> data;
  final String? selected;
  final String title;

  const ItemSelector(
      {super.key, required this.title, required this.data, this.selected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SettingsList(
              sections: [
                SettingsSection(
                  tiles: data
                      .map(
                        (e) => SettingsTile(
                          title: Text(e),
                          leading: e == selected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.check_rounded,
                                  color: Colors.grey[200],
                                ),
                          onPressed: (context) {
                            context.pop(e);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
