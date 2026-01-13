import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_animations.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_effects.dart';

/// Animated button with tap scale effect
/// Provides premium tactile feedback on press
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.scaleDown = 0.95,
    this.duration,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;

  /// Scale factor when pressed (default: 0.95)
  final double scaleDown;

  /// Animation duration
  final Duration? duration;

  /// Whether button is enabled
  final bool enabled;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppAnimations.instant,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: widget.enabled ? 1.0 : 0.5, child: widget.child),
          );
        },
      ),
    );
  }
}

/// Primary action button with gradient and glow
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height = 52,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: isLoading ? null : onPressed,
      enabled: enabled && !isLoading,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: enabled
              ? AppColors.primaryGradient
              : const LinearGradient(colors: [AppColors.surfaceVariant, AppColors.surfaceVariant]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled ? AppEffects.primaryGlow(intensity: 0.3) : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary/outline button
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height = 48,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: isLoading ? null : onPressed,
      enabled: enabled && !isLoading,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Icon button with scale animation
class AnimatedIconButton extends StatelessWidget {
  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedButton(
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, size: iconSize, color: iconColor ?? AppColors.textSecondary),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
