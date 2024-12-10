import 'package:askaide/helper/helper.dart';
import 'package:askaide/lang/lang.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';

class EnhancedErrorWidget extends StatelessWidget {
  final Object? error;
  const EnhancedErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: resolveError(context, error!),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                context.go('/login');
              },
              borderRadius: CustomSize.borderRadiusAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  AppLocale.clickToReSignin.getString(context),
                  textScaler: const TextScaler.linear(0.8),
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
