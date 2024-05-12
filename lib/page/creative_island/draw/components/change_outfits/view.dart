import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider.dart';

class ChangeOutfitsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ChangeOutfitsProvider(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.read<ChangeOutfitsProvider>();

    return Container();
  }
}

