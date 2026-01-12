import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => const AboutPage(), settings: settings);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text('About', style: MTextTheme.h4SemiBold.copyWith(color: AppColors.textPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.movie_filter_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: MTextTheme.h2Bold.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Version $_version',
              style: MTextTheme.body1Medium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            Text(
              'Designed & Developed by',
              style: MTextTheme.captionRegular.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 8),
            Text(
              'Antigravity Team',
              style: MTextTheme.body1SemiBold.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 64),
            // Links placeholder
            _buildLink('Terms of Service'),
            _buildLink('Privacy Policy'),
            _buildLink('Licenses'),
          ],
        ),
      ),
    );
  }

  Widget _buildLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton(
        onPressed: () {}, // TODO: Open links
        child: Text(text, style: MTextTheme.body2Medium.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}
