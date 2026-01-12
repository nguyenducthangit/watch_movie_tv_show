import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

/// Shimmer Loading Widget
/// Used for skeleton loading states
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key, required this.child, this.isLoading = true});
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Shimmer Box - Simple shimmer placeholder
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.borderRadius = 8});
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Video Card Skeleton
class VideoCardSkeleton extends StatelessWidget {
  const VideoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Duration
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// List Skeleton
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(16),
  });
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Grid Skeleton
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.aspectRatio = 0.7,
    this.padding = const EdgeInsets.all(16),
  });
  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const VideoCardSkeleton(),
    );
  }
}
