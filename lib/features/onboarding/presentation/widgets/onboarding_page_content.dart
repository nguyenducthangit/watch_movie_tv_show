import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/config/theme/m_text_theme.dart';
import '../../data/models/onboarding_model.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({super.key, required this.page});
  final OnboardingModel page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 12.0;
        // final imageSize = constraints.maxHeight - 100 - padding * 2;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Image.asset(
                page.imagePath,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: padding),
            Text(page.title.tr, style: MTextTheme.h3SemiBold, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                page.description.tr,
                style: MTextTheme.body2Regular,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
