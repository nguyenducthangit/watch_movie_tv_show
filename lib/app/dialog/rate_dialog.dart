import 'package:exo_shared/exo_shared.dart' hide SharedPrefService;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/translations/lang/l.dart';

import '../services/shared_pref_service.dart';
import '../utils/assets.gen.dart';

class RateDialog extends StatefulWidget {
  const RateDialog({super.key});

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  static const initialRating = 5;
  
  final rating = initialRating.obs;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: AppColors.white,
      child: SizedBox(
        width: context.width - 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 46),
                Expanded(
                  child: Text(
                    L.rateTitle.tr,
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MButton(
                  shape: BoxShape.circle,
                  padding: const EdgeInsets.all(8),
                  onPressed: Get.back,
                  child: Assets.icons.icClose.svg(height: 24, width: 24),
                ),
                const SizedBox(width: 6),
              ],
            ),
            Text(
              L.rateDescription.tr,
              style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Assets.images.bgRate.image(height: 150, width: 150),
            const SizedBox(height: 14),
            RatingBar.builder(
              itemCount: 5,
              initialRating: initialRating.toDouble(),
              itemBuilder: (context, index) {
                return Assets.icons.icRateEnable.svg();
              },
              itemSize: 28,
              itemPadding: const EdgeInsets.all(10),
              unratedColor: AppColors.black.withValues(alpha: 0.2),
              onRatingUpdate: (rating) => this.rating.value = rating.toInt(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: MButton(
                    borderRadius: BorderRadius.circular(33),
                    border: Border.all(color: AppColors.primary),
                    onPressed: Get.back,
                    child: Text(L.later.tr, style: textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: MButton(
                    borderRadius: BorderRadius.circular(33),
                    color: AppColors.primary,
                    onPressed: onSubmitPressed,
                    child: Text(
                      L.submit.tr,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> onSubmitPressed() async {
    SharedPrefService.setRated();

    if (rating.value < 5) {
      Get.back();
      _showThankYouMessage();
      return;
    }

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
    Get.back();
  }

  void _showThankYouMessage() {
    Get.snackbar(
      L.rateThankYou.tr,
      L.rateThankYouMessage.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
