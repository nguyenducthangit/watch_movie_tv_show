import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_animations.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';

/// Player Gesture Layer
/// Handles touch gestures for video player controls:
/// - Left side vertical drag: Brightness control
/// - Right side vertical drag: Volume control
/// - Double tap left: Seek backward 10s
/// - Double tap right: Seek forward 10s
/// - Single tap: Toggle controls visibility
class PlayerGestureLayer extends StatefulWidget {
  const PlayerGestureLayer({
    super.key,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onTap,
    this.seekSeconds = 10,
    this.enabled = true,
  });

  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onTap;
  final int seekSeconds;
  final bool enabled;

  @override
  State<PlayerGestureLayer> createState() => _PlayerGestureLayerState();
}

class _PlayerGestureLayerState extends State<PlayerGestureLayer> {
  // State
  bool _showVolumeIndicator = false;
  bool _showBrightnessIndicator = false;
  bool _showSeekForward = false;
  bool _showSeekBackward = false;
  double _volume = 0.5;
  double _brightness = 0.5;

  // Gesture tracking
  double _dragStartY = 0;
  bool _isDraggingLeft = false;
  bool _isDraggingRight = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  Future<void> _initValues() async {
    try {
      _brightness = await ScreenBrightness().current;
    } catch (_) {
      _brightness = 0.5;
    }
    // Note: Getting system volume requires platform channels
    // For now we just track relative changes
    if (mounted) setState(() {});
  }

  void _onVerticalDragStart(DragStartDetails details, bool isLeftSide) {
    _dragStartY = details.localPosition.dy;
    if (isLeftSide) {
      _isDraggingLeft = true;
      _showBrightnessIndicator = true;
    } else {
      _isDraggingRight = true;
      _showVolumeIndicator = true;
    }
    setState(() {});
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, bool isLeftSide) {
    final delta = (_dragStartY - details.localPosition.dy) / 200;
    _dragStartY = details.localPosition.dy;

    if (isLeftSide && _isDraggingLeft) {
      // Brightness control
      _brightness = (_brightness + delta).clamp(0.0, 1.0);
      _setBrightness(_brightness);
    } else if (!isLeftSide && _isDraggingRight) {
      // Volume control
      _volume = (_volume + delta).clamp(0.0, 1.0);
      _setVolume(_volume);
    }
    setState(() {});
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
          _showBrightnessIndicator = false;
          _isDraggingLeft = false;
          _isDraggingRight = false;
        });
      }
    });
  }

  Future<void> _setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
    } catch (_) {
      // Ignore errors
    }
  }

  void _setVolume(double value) {
    // Platform channel would be needed for system volume
    // For now this is handled by the video player itself
  }

  void _onDoubleTapLeft() {
    if (!widget.enabled) return;
    setState(() => _showSeekBackward = true);
    widget.onSeekBackward();
    Future.delayed(AppAnimations.medium, () {
      if (mounted) setState(() => _showSeekBackward = false);
    });
  }

  void _onDoubleTapRight() {
    if (!widget.enabled) return;
    setState(() => _showSeekForward = true);
    widget.onSeekForward();
    Future.delayed(AppAnimations.medium, () {
      if (mounted) setState(() => _showSeekForward = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left side gesture area (brightness)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.4,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: (d) => _onVerticalDragStart(d, true),
            onVerticalDragUpdate: (d) => _onVerticalDragUpdate(d, true),
            onVerticalDragEnd: _onVerticalDragEnd,
            onDoubleTap: _onDoubleTapLeft,
            onTap: widget.onTap,
            child: const SizedBox.expand(),
          ),
        ),

        // Right side gesture area (volume)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.4,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: (d) => _onVerticalDragStart(d, false),
            onVerticalDragUpdate: (d) => _onVerticalDragUpdate(d, false),
            onVerticalDragEnd: _onVerticalDragEnd,
            onDoubleTap: _onDoubleTapRight,
            onTap: widget.onTap,
            child: const SizedBox.expand(),
          ),
        ),

        // Center tap area
        Positioned(
          left: MediaQuery.of(context).size.width * 0.4,
          right: MediaQuery.of(context).size.width * 0.4,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onTap,
            child: const SizedBox.expand(),
          ),
        ),

        // Volume indicator
        if (_showVolumeIndicator)
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: Center(
              child: _VerticalIndicator(
                icon: _getVolumeIcon(),
                value: _volume,
                label: '${(_volume * 100).round()}%',
              ),
            ),
          ),

        // Brightness indicator
        if (_showBrightnessIndicator)
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: Center(
              child: _VerticalIndicator(
                icon: Icons.brightness_6_rounded,
                value: _brightness,
                label: '${(_brightness * 100).round()}%',
              ),
            ),
          ),

        // Seek backward indicator
        if (_showSeekBackward)
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: Center(
              child: _SeekIndicator(
                icon: Icons.replay_10_rounded,
                label: '-${widget.seekSeconds}s',
              ),
            ),
          ),

        // Seek forward indicator
        if (_showSeekForward)
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: Center(
              child: _SeekIndicator(
                icon: Icons.forward_10_rounded,
                label: '+${widget.seekSeconds}s',
              ),
            ),
          ),
      ],
    );
  }

  IconData _getVolumeIcon() {
    if (_volume <= 0) return Icons.volume_off_rounded;
    if (_volume < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }
}

/// Vertical progress indicator for volume/brightness
class _VerticalIndicator extends StatelessWidget {
  const _VerticalIndicator({required this.icon, required this.value, required this.label});

  final IconData icon;
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Container(
            width: 6,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 6,
                height: 100 * value,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: MTextTheme.captionMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Seek indicator with ripple effect
class _SeekIndicator extends StatelessWidget {
  const _SeekIndicator({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 8),
          Text(label, style: MTextTheme.body1SemiBold.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
