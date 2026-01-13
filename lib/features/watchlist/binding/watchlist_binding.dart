import 'package:get/get.dart';
import 'package:watch_movie_tv_show/features/watchlist/controller/watchlist_controller.dart';

/// Watchlist Binding
class WatchlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WatchlistController());
  }
}
