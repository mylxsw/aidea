import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

ImageProvider resolveImageProvider(String imageUrl) {
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return CachedNetworkImageProviderEnhanced(imageUrl);
  }

  return FileImage(File(imageUrl));
}

class CachedNetworkImageEnhanced extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final ImageWidgetBuilder? imageBuilder;
  final BaseCacheManager? cacheManager;

  CachedNetworkImageEnhanced({
    super.key,
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.imageBuilder,
    this.cacheManager,
  }) {
    // Logger.instance.d('load image: $imageUrl');
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      progressIndicatorBuilder: progressIndicatorBuilder,
      errorWidget: errorWidget,
      imageBuilder: imageBuilder,
      cacheManager: cacheManager,
    );
  }
}

class CachedNetworkImageProviderEnhanced extends CachedNetworkImageProvider {
  CachedNetworkImageProviderEnhanced(
    super.url, {
    super.maxHeight,
    super.maxWidth,
    super.scale = 1.0,
    super.errorListener,
    super.headers,
    super.cacheManager,
    super.cacheKey,
  }) {
    // Logger.instance.d('load image: $url');
  }
}
