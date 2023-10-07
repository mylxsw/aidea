import 'package:askaide/page/component/gradient_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NotifyMessageWidget extends StatelessWidget {
  final Function()? onClose;
  final Widget child;
  final String? backgroundImageUrl;
  final double height;
  final Widget? title;
  final bool closeable;
  const NotifyMessageWidget({
    super.key,
    this.onClose,
    required this.child,
    this.backgroundImageUrl,
    this.height = 100,
    this.title,
    this.closeable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
        top: 7,
      ),
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // gradient: buildGradientStyle(),
          // color: Color.fromARGB(255, 252, 188, 188),
          image: backgroundImageUrl != null
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(backgroundImageUrl!),
                )
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (title != null) title! else const SizedBox(),
                if (closeable)
                  InkWell(
                    onTap: () {
                      onClose?.call();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(184, 37, 37, 37),
                        borderRadius: BorderRadius.circular(80),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(
                        Icons.close,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 12,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),
            if (title != null) const SizedBox(height: 3),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  LinearGradient buildGradientStyle() {
    return GradientStyle.warmLinear();
  }
}
