import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  void setLoading(bool loading) {
    isLoading.value = loading;
  }


Future<String> fetchUserName() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Guest';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['name'] ?? 'User';
    } else {
      return 'User';
    }
  } catch (e) {
    return 'User';
  }
}
}
