
import '../../../app/services/shared_pref_service.dart';

class SettingsRepository {
  // Rate settings
  bool getRated() {
    return SharedPrefService.getRated();
  }

  void setRated() {
    SharedPrefService.setRated();
  }

  // Language settings
  String? getLanguage() {
    return SharedPrefService.getLang();
  }
}
