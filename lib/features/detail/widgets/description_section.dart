import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

/// Description Section Widget
/// Expandable description with "Read more" functionality
class DescriptionSection extends StatefulWidget {
  const DescriptionSection({required this.description, this.maxLines = 3, super.key});

  final String description;
  final int maxLines;

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(L.contents.tr, style: MTextTheme.body1SemiBold.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),

        // Description text with animation
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Text(
            widget.description,
            maxLines: _isExpanded ? null : widget.maxLines,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: MTextTheme.body2Regular.copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
        ),

        // Read more button
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? L.collapse.tr : L.seeMore.tr,
                  style: MTextTheme.body2SemiBold.copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
