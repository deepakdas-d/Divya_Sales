import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeController extends GetxController {
  var totalLeads = 100.obs;
  var selectedIndex = (-1).obs; // -1 means no selection
  var isMenuOpen = false.obs;
  var isLoading = false.obs;

  void updateLeads(int value) {
    totalLeads.value = value;
  }

  void selectMenuItem(int index) {
    selectedIndex.value = index;
    // Reset selection after navigation simulation
    Future.delayed(const Duration(milliseconds: 100), () {
      selectedIndex.value = -1;
    });
  }

  void toggleMenu() {
    isMenuOpen.value = !isMenuOpen.value;
  }
}
