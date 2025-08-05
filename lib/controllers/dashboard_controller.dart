// lib/controllers/dashboard_controller.dart
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxString userRole = ''.obs;

  void updateTabIndex(int index) {
    selectedIndex.value = index;
  }

  void setUserRole(String role) {
    userRole.value = role;
  }
}