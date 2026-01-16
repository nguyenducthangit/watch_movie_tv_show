// import 'package:flutter/material.dart';
// import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
// import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';

// class PlayerGestureLayer extends StatefulWidget {
//   const PlayerGestureLayer({
//     super.key,
//     required this.onSeekForward,
//     required this.onSeekBackward,
//     required this.onTap,
//     this.seekSeconds = 10,
//     this.enabled = true,
//   });

//   final VoidCallback onSeekForward;
//   final VoidCallback onSeekBackward;
//   final VoidCallback onTap;
//   final int seekSeconds;
//   final bool enabled;

//   @override
//   State<PlayerGestureLayer> createState() => _PlayerGestureLayerState();
// }

// class _PlayerGestureLayerState extends State<PlayerGestureLayer> {
//   final bool _showSeekForward = false;
//   final bool _showSeekBackward = false;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           left: 0,
//           top: 0,
//           bottom: 0,
//           width: MediaQuery.of(context).size.width * 0.4,
//           child: GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: widget.onTap,
//             child: const SizedBox.expand(),
//           ),
//         ),

//         Positioned(
//           right: 0,
//           top: 0,
//           bottom: 0,
//           width: MediaQuery.of(context).size.width * 0.4,
//           child: GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: widget.onTap,
//             child: const SizedBox.expand(),
//           ),
//         ),

//         Positioned(
//           left: MediaQuery.of(context).size.width * 0.4,
//           right: MediaQuery.of(context).size.width * 0.4,
//           top: 0,
//           bottom: 0,
//           child: GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: widget.onTap,
//             child: const SizedBox.expand(),
//           ),
//         ),

//         if (_showSeekBackward)
//           Positioned(
//             left: 40,
//             top: 0,
//             bottom: 0,
//             child: Center(
//               child: _SeekIndicator(
//                 icon: Icons.replay_10_rounded,
//                 label: '-${widget.seekSeconds}s',
//               ),
//             ),
//           ),

//         if (_showSeekForward)
//           Positioned(
//             right: 40,
//             top: 0,
//             bottom: 0,
//             child: Center(
//               child: _SeekIndicator(
//                 icon: Icons.forward_10_rounded,
//                 label: '+${widget.seekSeconds}s',
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class _SeekIndicator extends StatelessWidget {
//   const _SeekIndicator({required this.icon, required this.label});

//   final IconData icon;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: AppColors.black.withValues(alpha: 0.7),
//         borderRadius: BorderRadius.circular(40),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.white, size: 32),
//           const SizedBox(width: 8),
//           Text(label, style: MTextTheme.body1SemiBold.copyWith(color: Colors.white)),
//         ],
//       ),
//     );
//   }
// }
