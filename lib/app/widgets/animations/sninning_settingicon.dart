import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class SpinningSettingIcon extends StatefulWidget {
  const SpinningSettingIcon({
    super.key,
    required this.onTap,
    required this.icon,
    this.transition = Transition.cupertino,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCubic,
  });
  final VoidCallback onTap;
  final Icon icon;
  final Transition transition;
  final Duration duration;
  final Curve curve;

  @override
  State<SpinningSettingIcon> createState() => _SpinningSettingIconState();
}

class _SpinningSettingIconState extends State<SpinningSettingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: RotationTransition(
          turns: _controller,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            // child: Image.asset(widget.assetPath),
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}
