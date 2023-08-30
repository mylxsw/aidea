import 'package:askaide/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnhancedErrorWidget extends StatelessWidget {
  final Object? error;
  const EnhancedErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return Container();
    }

    return Center(
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
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                '点击此处重新登录',
                textScaleFactor: 0.8,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
