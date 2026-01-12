/// Asset Paths
class AppAssets {
  AppAssets._();

  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _data = 'assets/data';

  // Images
  static const String logo = '$_images/logo.png';
  static const String placeholder = '$_images/placeholder.png';
  static const String emptyState = '$_images/empty_state.png';
  static const String errorState = '$_images/error_state.png';
  static const String offlineState = '$_images/offline_state.png';
  static const String noVideo = '$_images/no_video.png';

  // Icons
  static const String icHome = '$_icons/ic_home.svg';
  static const String icDownload = '$_icons/ic_download.svg';
  static const String icSettings = '$_icons/ic_settings.svg';
  static const String icPlay = '$_icons/ic_play.svg';
  static const String icPause = '$_icons/ic_pause.svg';
  static const String icSearch = '$_icons/ic_search.svg';
  static const String icClose = '$_icons/ic_close.svg';
  static const String icCheck = '$_icons/ic_check.svg';
  static const String icError = '$_icons/ic_error.svg';
  static const String icOffline = '$_icons/ic_offline.svg';

  // Data - Mock manifest
  static const String mockManifest = '$_data/manifest.json';
}
