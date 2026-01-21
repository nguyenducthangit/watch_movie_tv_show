import 'package:exo_shared/exo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/utils/assets.gen.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(0),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: SvgPicture.asset(icon, height: 24, width: 24)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: MTextTheme.body1Regular,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle != null) ...[
            Text(subtitle!, style: MTextTheme.captionRegular.copyWith(color: AppColors.primary)),
            const SizedBox(width: 6),
          ],
          
          Assets.icons.icChevronRight.svg(width: 20, height: 20, color: AppColors.primary),
        ],
      ),
    );
  }
}
