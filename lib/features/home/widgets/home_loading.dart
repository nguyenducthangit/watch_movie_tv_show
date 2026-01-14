import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/widgets/shimmer_loading.dart';

class HomeLoading extends StatelessWidget {
  const HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 80),
          HeroCarouselSkeleton(),
          SizedBox(height: 32),
          ContinueWatchingSkeleton(),
          SizedBox(height: 32),
          CategoryRowSkeleton(),
          SizedBox(height: 24),
          CategoryRowSkeleton(itemWidth: 200, itemHeight: 280),
        ],
      ),
    );
  }
}
