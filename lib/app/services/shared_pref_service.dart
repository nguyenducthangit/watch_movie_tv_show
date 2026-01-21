import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static late SharedPreferences _sharedPreferences;

  static bool? _isFirstLaunchCached;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    // Tính và cache ngay sau khi init
    final launched = _sharedPreferences.getBool(_kLaunchedKey) ?? false;
    if (!launched) {
      await _sharedPreferences.setBool(_kLaunchedKey, true);
      _isFirstLaunchCached = true; // lần đầu
    } else {
      _isFirstLaunchCached = false; // từ lần 2 trở đi
    }
  }

  static bool get isFirstLaunchCached => _isFirstLaunchCached ?? true;

  static Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static String? getLang() {
    return _sharedPreferences.getString('lang');
  }

  static void setLang(String lang) {
    _sharedPreferences.setString('lang', lang);
  }

  static void setRated() {
    _sharedPreferences.setBool('rated', true);
  }

  static bool getRated() {
    return _sharedPreferences.getBool('rated') ?? false;
  }

  static int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  static void setInt(String key, int value) {
    _sharedPreferences.setInt(key, value);
  }

  static void remove(String key) {
    _sharedPreferences.remove(key);
  }

  // Feature usage count methods for rating dialog
  static int getFeatureUsageCount() {
    return _sharedPreferences.getInt('feature_usage_count') ?? 0;
  }

  static void incrementFeatureUsageCount() {
    final int currentCount = getFeatureUsageCount();
    _sharedPreferences.setInt('feature_usage_count', currentCount + 1);
  }

  static bool shouldShowRatingDialog() {
    if (getRated()) return false; // Đã rate rồi thì không hiện nữa

    final int usageCount = getFeatureUsageCount();
    // Hiện rating ở lần lẻ: 1, 3, 5, 7,...
    return usageCount > 0 && usageCount % 2 == 1;
  }

  // ===== First launch tracking =====
  static const _kLaunchedKey = 'app_has_launched';

  // Nếu vẫn muốn dùng hàm async, giờ sẽ ưu tiên cache trước
  static Future<bool> isFirstLaunch() async {
    if (_isFirstLaunchCached != null) return _isFirstLaunchCached!;
    final launched = _sharedPreferences.getBool(_kLaunchedKey) ?? false;
    if (!launched) {
      await _sharedPreferences.setBool(_kLaunchedKey, true);
      _isFirstLaunchCached = true;
      return true;
    }
    _isFirstLaunchCached = false;
    return false;
  }

  static Future<bool> isSecondLaunchOrLater() async {
    return !(await isFirstLaunch());
  }

  static SharedPreferences get instance => _sharedPreferences;

  // ===== Copyright notice tracking =====
  static const _kCopyrightNoticeShownKey = 'copyright_notice_shown';

  /// Check if copyright notice has been shown
  static bool hasCopyrightNoticeBeenShown() {
    return _sharedPreferences.getBool(_kCopyrightNoticeShownKey) ?? false;
  }

  /// Mark copyright notice as shown
  static Future<void> markCopyrightNoticeAsShown() async {
    await _sharedPreferences.setBool(_kCopyrightNoticeShownKey, true);
  }
}
