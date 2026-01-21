import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

/// Copyright Notice Popup
/// Displayed once on first app launch to explain English-only content
class DataSourcePolicyPopup extends StatelessWidget {
  const DataSourcePolicyPopup({super.key});

  /// Show popup dialog
  static void show() {
    Get.dialog(
      const DataSourcePolicyPopup(),
      barrierDismissible: false,
      // Sử dụng withValues cho Flutter mới (thay cho withOpacity)
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.public_rounded, // Icon mới
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              L.contentMetadataStandards.tr,
              style: MTextTheme.h3SemiBold.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              L.contentMetadataStandardsMessage.tr,
              style: MTextTheme.body1Regular.copyWith(color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(L.ok.tr, style: MTextTheme.body1SemiBold.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
