import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';
import 'package:watch_movie_tv_show/features/settings/binding/settings_binding.dart';
import 'package:watch_movie_tv_show/features/settings/controller/settings_controller.dart';

/// Settings Page (standalone route)
class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const SettingsPage(),
    settings: settings,
    routeName: MRoutes.settings,
    binding: SettingsBinding(),
  );

  @override
  Widget build(BuildContext context) {
    return const SettingsContent();
  }
}

/// Settings Content (used in MainNav)
class SettingsContent extends GetView<SettingsController> {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Text(
                AppStrings.settingsTitle,
                style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary),
              ),
            ),

            // Settings list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Storage section
                  const _SectionTitle(title: 'Storage'),
                  const SizedBox(height: 12),

                  Obx(
                    () => _SettingsItem(
                      icon: Icons.image_outlined,
                      title: AppStrings.clearCache,
                      subtitle: AppStrings.clearCacheDescription,
                      isLoading: controller.isClearingCache.value,
                      onTap: controller.clearImageCache,
                    ),
                  ),

                  Obx(
                    () => _SettingsItem(
                      icon: Icons.delete_outline_rounded,
                      title: AppStrings.clearAllDownloads,
                      subtitle: AppStrings.clearAllDescription,
                      isLoading: controller.isClearingDownloads.value,
                      onTap: controller.clearAllDownloads,
                      isDestructive: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About section
                  const _SectionTitle(title: AppStrings.about),
                  const SizedBox(height: 12),

                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    title: AppStrings.version,
                    subtitle: controller.appVersion,
                    showChevron: true,
                    onTap: () => Get.toNamed(MRoutes.about),
                  ),

                  const _SettingsItem(
                    icon: Icons.cloud_outlined,
                    title: AppStrings.manifestSource,
                    subtitle: 'GitHub',
                    showChevron: false,
                  ),

                  const SizedBox(height: 32),

                  // App logo and name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.appName,
                          style: MTextTheme.body1SemiBold.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${controller.appVersion}',
                          style: MTextTheme.captionRegular.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section Title
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: MTextTheme.captionMedium.copyWith(color: AppColors.textTertiary, letterSpacing: 1),
    );
  }
}

/// Settings Item
class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showChevron = true,
    this.isDestructive = false,
    this.isLoading = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool isDestructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: MTextTheme.body1Medium.copyWith(
                          color: isDestructive ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: MTextTheme.captionRegular.copyWith(color: AppColors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (showChevron && onTap != null)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
