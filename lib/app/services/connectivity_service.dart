import 'dart:async';

// import 'package:anime_sandbox/common/popups/no_internet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends SuperController implements GetxService {
  final isConnectInternet = false.obs;
  final isConnectWifi = false.obs;
  final canShow = false.obs;
  StreamSubscription? streamConnectSub;
  DialogRoute? router;

  @override
  void onInit() {
    streamConnectSub = Connectivity().onConnectivityChanged.listen((event) {
      checkInternetConnect(event);
      checkWifiConnect(event);
    });
    super.onInit();
  }

  void checkInternetConnect(List<ConnectivityResult> event) {
    if (event.contains(ConnectivityResult.wifi) || event.contains(ConnectivityResult.mobile)) {
      hideNoInternetDialog();
      isConnectInternet.value = true;
    } else {
      isConnectInternet.value = false;
      showNoInternetDialog(() {});
    }
  }

  void checkWifiConnect(List<ConnectivityResult> event) {
    if (event.contains(ConnectivityResult.wifi)) {
      isConnectWifi.value = true;
    } else {
      isConnectWifi.value = false;
    }
  }

  Future<void> showNoInternetDialog(VoidCallback onComplete) async {
    if (router != null) {
      hideNoInternetDialog();
    }
    if (!canShow.value) {
      return;
    }
    if (Get.context != null) {
      // router = DialogRoute(
      //   context: Get.context!,
      //   builder: (context) => const NoInternet(),
      // );
      await Navigator.push(Get.context!, router!).whenComplete(onComplete);
    }
  }

  Future<void> showNoInternetDialogFO(VoidCallback onComplete) async {
    // Get.dialog(const NoInternet());
    isConnectInternet.listen((value) {
      if (value) {
        Get.back();
        onComplete();
      }
    });
  }

  Future<void> hideNoInternetDialog() async {
    if (Get.context != null && router != null) {
      Navigator.removeRoute(Get.context!, router!);
      router = null;
    }
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
