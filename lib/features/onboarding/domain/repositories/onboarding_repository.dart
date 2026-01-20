import '../../data/models/onboarding_model.dart';

abstract class IOnboardingRepository {
  List<OnboardingModel> getOnboardingPages();
}
