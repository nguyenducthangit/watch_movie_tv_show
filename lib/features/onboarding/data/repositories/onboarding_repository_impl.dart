import '../../domain/repositories/onboarding_repository.dart';
import '../models/onboarding_model.dart';
import '../../presentation/constants/onboarding_constants.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  @override
  List<OnboardingModel> getOnboardingPages() => OnboardingConstants.onboardingPages;
}
