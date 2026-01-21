import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:watch_movie_tv_show/app/popups/no_internet.dart';

class ConnectivityService extends GetxService {
  final isConnectInternet = true.obs;
  final isConnectWifi = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _streamConnectSub;
  bool _isDialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startListening();
  }

  /// Kiểm tra kết nối ban đầu
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectivityStatus(result);
    } catch (e) {
      debugPrint('ConnectivityService init error: $e');
    }
  }

  /// Lắng nghe thay đổi kết nối
  void _startListening() {
    _streamConnectSub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        _updateConnectivityStatus(result);
      },
      onError: (error) {
        debugPrint('ConnectivityService listen error: $error');
      },
    );
  }

  /// Cập nhật trạng thái kết nối và hiển thị popup nếu cần
  void _updateConnectivityStatus(List<ConnectivityResult> result) {
    final hasConnection =
        result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

    // Cập nhật wifi status
    isConnectWifi.value = result.contains(ConnectivityResult.wifi);

    // Nếu mất kết nối thì hiện popup
    if (!hasConnection && !_isDialogShowing) {
      isConnectInternet.value = false;
      _showNoInternetDialog();
    }
    // Nếu có kết nối trở lại thì ẩn popup
    else if (hasConnection && _isDialogShowing) {
      isConnectInternet.value = true;
      _hideNoInternetDialog();
    }
    // Nếu có kết nối và chưa hiện popup
    else if (hasConnection) {
      isConnectInternet.value = true;
    }
  }

  /// Hiển thị popup no internet
  void _showNoInternetDialog() {
    if (_isDialogShowing || Get.context == null) return;

    _isDialogShowing = true;
    Get.dialog(const NoInternet(), barrierDismissible: false, name: 'no_internet_dialog');
  }

  /// Ẩn popup no internet
  void _hideNoInternetDialog() {
    if (!_isDialogShowing) return;

    _isDialogShowing = false;
    // Đóng dialog nếu đang mở
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  @override
  void onClose() {
    _streamConnectSub?.cancel();
    super.onClose();
  }
}
