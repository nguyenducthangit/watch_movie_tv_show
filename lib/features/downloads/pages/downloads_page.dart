import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/m_routes.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';
import 'package:watch_movie_tv_show/app/widgets/empty_state_widget.dart';
import 'package:watch_movie_tv_show/features/downloads/binding/downloads_binding.dart';
import 'package:watch_movie_tv_show/features/downloads/controller/downloads_controller.dart';
import 'package:watch_movie_tv_show/features/downloads/widgets/download_appbar.dart';
import 'package:watch_movie_tv_show/features/downloads/widgets/widgets.dart';

/// Downloads Page (standalone route)
class DownloadsPage extends GetView<DownloadsController> {
  const DownloadsPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const DownloadsPage(),
    settings: settings,
    routeName: MRoutes.downloads,
    binding: DownloadsBinding(),
  );

  @override
  Widget build(BuildContext context) {
    return const DownloadsContent();
  }
}

/// Downloads Content (used in MainNav)
class DownloadsContent extends GetView<DownloadsController> {
  const DownloadsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          // Empty state
          if (!controller.hasDownloads) {
            return Column(
              children: [
                const DownloadAppBar(),
                Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.download_outlined,
                    title: L.noDownloads.tr,
                    message: L.noDownloadsDescription.tr,
                  ),
                ),
              ],
            );
          }

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DownloadAppBar(),

                  // Storage info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.storage_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text(
                          '${L.storageUsed.tr}: ${controller.storageUsedString}',
                          style: MTextTheme.captionRegular.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Active downloads section
                        if (controller.activeDownloads.isNotEmpty) ...[
                          DownloadSectionHeader(
                            title: L.activeDownloads.tr,
                            count: controller.activeDownloads.length,
                          ),
                          const SizedBox(height: 12),
                          ...controller.activeDownloads.map(
                            (task) => DownloadActiveItem(
                              task: task,
                              onCancel: () => controller.cancelDownload(task.videoId),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Completed downloads section
                        if (controller.completedDownloads.isNotEmpty) ...[
                          DownloadSectionHeader(
                            title: L.completedDownloads.tr,
                            count: controller.completedDownloads.length,
                          ),
                          const SizedBox(height: 12),
                          ...controller.completedDownloads.map(
                            (task) => DownloadItem(
                              task: task,
                              isEditMode: controller.isEditMode.value,
                              isSelected: controller.isSelected(task.videoId),
                              onToggleSelect: () => controller.toggleSelection(task.videoId),
                              onPlay: () => controller.routeVideoDetails(task),
                              onDelete: () => controller.deleteDownload(task.videoId),
                            ),
                          ),
                        ],
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom action bar (edit mode)
              if (controller.isEditMode.value && controller.selectedCount > 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: DownloadBottomActionBar(controller: controller),
                ),
            ],
          );
        }),
      ),
    );
  }
}
