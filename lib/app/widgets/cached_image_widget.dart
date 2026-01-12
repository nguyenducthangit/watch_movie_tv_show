import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/widgets/shimmer_loading.dart';

/// Cached Image Widget
/// Wrapper for cached_network_image with default placeholder and error handling
class CachedImageWidget extends StatelessWidget {
  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            placeholder ??
            ShimmerBox(
              width: width,
              height: height,
              borderRadius: borderRadius != null
                  ? borderRadius!
                        .topLeft
                        .x // Approximation or just 0 if complex
                  : 0,
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.broken_image_rounded,
                color: AppColors.textTertiary,
                size: 32,
              ),
            ),
      ),
    );
  }
}

/// Thumbnail Image Widget
/// Specialized for video thumbnails with aspect ratio
class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    this.overlay,
  });
  final String imageUrl;
  final double? width;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImageWidget(
            imageUrl: imageUrl,
            width: width,
            fit: BoxFit.cover,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}
