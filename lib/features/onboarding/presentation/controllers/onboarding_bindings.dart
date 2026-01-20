import 'package:get/get.dart';

import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_controller.dart';

class OnboardingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IOnboardingRepository>(() => OnboardingRepositoryImpl());
    Get.lazyPut(() => OnboardingController(Get.find<IOnboardingRepository>()));
  }
}
