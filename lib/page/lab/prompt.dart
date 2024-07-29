import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/effect/glass.dart';
import 'package:askaide/page/component/enhanced_button.dart';
import 'package:askaide/page/component/enhanced_textfield.dart';
import 'package:askaide/page/component/item_selector_search.dart';
import 'package:askaide/page/component/dialog.dart';
import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class PromptScreen extends StatefulWidget {
  final String? prompt;

  const PromptScreen({super.key, this.prompt});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  TextEditingController controller = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    controller.text = widget.prompt ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.prompt.getString(context)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          EnhancedTextField(
            labelText: AppLocale.prompt.getString(context),
            labelPosition: LabelPosition.top,
            inputSelector: InputSelector(
              title: Text(
                AppLocale.examples.getString(context),
                style: TextStyle(color: customColors.linkColor),
                textScaler: const TextScaler.linear(0.8),
              ),
              onTap: () {
                openSystemPromptSelectDialog(
                  context,
                  customColors,
                );
              },
            ),
            customColors: customColors,
            controller: controller,
            maxLines: 6,
            minLines: 2,
            maxLength: 500,
            hintText: AppLocale.promptHint.getString(context),
          ),
          const SizedBox(height: 20),
          EnhancedButton(
            title: AppLocale.ok.getString(context),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ]),
      ),
    );
  }

  void openSystemPromptSelectDialog(
    BuildContext context,
    CustomColors customColors,
  ) {
    openModalBottomSheet(
      context,
      (context) {
        return FutureBuilder(
          future: APIServer().prompts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              showErrorMessage(resolveError(context, snapshot.error!));
            }

            return FractionallySizedBox(
              heightFactor: 0.8,
              child: GlassEffect(
                child: ItemSearchSelector(
                  items: (snapshot.data ?? [])
                      .map(
                        (e) => SelectorItem<String>(
                          Text(
                            e.title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: customColors.chatExampleItemText,
                            ),
                          ),
                          e.content,
                          search: (keywrod) => e.title
                              .toLowerCase()
                              .contains(keywrod.toLowerCase()),
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    controller.text = value.value;
                    return true;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
