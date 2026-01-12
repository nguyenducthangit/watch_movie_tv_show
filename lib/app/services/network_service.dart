import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/utils/helpers.dart';

class NetworkService extends GetxService {
  static NetworkService get to => Get.find();

  final RxBool isOnline = true.obs;
  late final Connectivity _connectivity;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      logger.e('Connectivity check failed: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If any result is not none, we are connected (simplification)
    final bool hasConnection = results.any((result) => result != ConnectivityResult.none);

    if (isOnline.value != hasConnection) {
      isOnline.value = hasConnection;
      logger.i('Connection status changed: ${hasConnection ? 'Online' : 'Offline'}');

      if (!hasConnection) {
        Get.snackbar(
          'Offline Mode',
          'You are currently offline. Showing downloaded content.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
