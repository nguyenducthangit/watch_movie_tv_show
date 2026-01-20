import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/config/m_routes.dart';
import '../controllers/onboarding_bindings.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/widgets.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  static Route<dynamic> getPageRoute(RouteSettings settings) => GetPageRoute(
    page: () => const OnboardingPage(),
    settings: settings,
    routeName: MRoutes.onboarding,
    binding: OnboardingBindings(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Assets.images.bgOnboarding.image(
          //   height: context.height,
          //   width: context.width,
          //   fit: BoxFit.cover,
          // ),
          Column(
            children: [
              Expanded(
                child: Obx(
                  () => PageView.builder(
                    onPageChanged: (index) => controller.onPageChanged(index),
                    itemCount: controller.pages.length,
                    controller: controller.pageController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      // if (page.title == OnboardingConstants.onboardingNativeFull) {
                      //   return OnboardingNativeFull();
                      // }
                      return OnboardingPageContent(
                        key: Key('${index}_${page.hashCode}'),
                        page: page,
                      );
                    },
                  ),
                ),
              ),
              Obx(
                () => controller.showNativeFull.value
                    ? const SizedBox.shrink()
                    : const OnboardingIndicatorView(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
