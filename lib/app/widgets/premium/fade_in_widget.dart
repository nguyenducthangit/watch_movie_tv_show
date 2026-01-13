import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_animations.dart';

/// Fade-in widget with optional slide animation
/// Used for staggered list item animations
class FadeInWidget extends StatefulWidget {
  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration,
    this.curve,
    this.slideOffset,
    this.scaleFrom,
    this.onComplete,
  });

  final Widget child;

  /// Delay before animation starts (for staggering)
  final Duration delay;

  /// Animation duration
  final Duration? duration;

  /// Animation curve
  final Curve? curve;

  /// Optional slide offset (e.g., Offset(0, 0.3) slides from bottom)
  final Offset? slideOffset;

  /// Optional scale start value (e.g., 0.8 scales up from 80%)
  final double? scaleFrom;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset>? _slideAnimation;
  late final Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppAnimations.normal,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.enterCurve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    _slideAnimation = widget.slideOffset != null
        ? Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(curve)
        : null;

    _scaleAnimation = widget.scaleFrom != null
        ? Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(curve)
        : null;

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget result = Opacity(opacity: _fadeAnimation.value, child: child);

        if (_scaleAnimation case final anim?) {
          result = Transform.scale(scale: anim.value, child: result);
        }

        if (_slideAnimation case final anim?) {
          result = FractionalTranslation(translation: anim.value, child: result);
        }

        return result;
      },
      child: widget.child,
    );
  }
}

/// Staggered list wrapper that animates children with delay
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration,
    this.slideFromBottom = true,
    this.scaleUp = false,
  });

  final List<Widget> children;

  /// Delay between each item animation
  final Duration staggerDelay;

  /// Duration for each item animation
  final Duration? itemDuration;

  /// Slide from bottom effect
  final bool slideFromBottom;

  /// Scale up effect
  final bool scaleUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(children.length, (index) {
        return FadeInWidget(
          delay: AppAnimations.staggerDelay(index, baseDelay: staggerDelay),
          duration: itemDuration,
          slideOffset: slideFromBottom ? const Offset(0, 0.2) : null,
          scaleFrom: scaleUp ? 0.9 : null,
          child: children[index],
        );
      }),
    );
  }
}

/// Staggered grid wrapper for GridView items
class StaggeredItem extends StatelessWidget {
  const StaggeredItem({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;

  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      delay: AppAnimations.staggerDelay(index, baseDelay: staggerDelay),
      slideOffset: const Offset(0, 0.15),
      scaleFrom: 0.92,
      child: child,
    );
  }
}

/// Simple fade in without stagger - for single elements
class SimpleFadeIn extends StatefulWidget {
  const SimpleFadeIn({super.key, required this.child, this.duration, this.delay = Duration.zero});

  final Widget child;
  final Duration? duration;
  final Duration delay;

  @override
  State<SimpleFadeIn> createState() => _SimpleFadeInState();
}

class _SimpleFadeInState extends State<SimpleFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppAnimations.normal,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: AppAnimations.fadeCurve),
      child: widget.child,
    );
  }
}
