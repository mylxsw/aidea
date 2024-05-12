import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider.dart';

class SelectorCropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => Selector_cropProvider(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.read<Selector_cropProvider>();

    return Container();
  }
}

