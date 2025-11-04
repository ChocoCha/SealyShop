import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();


  final carouselCurrentIndexs = 0.obs;

  void updatePageIndicator(int index) {
    carouselCurrentIndexs.value = index;
  }
}