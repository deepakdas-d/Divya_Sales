import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeadManagementController extends GetxController {
  final nameController = TextEditingController();
  final placeController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final phone2Controller = TextEditingController();
  final nosController = TextEditingController();
  final remarkController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  var selectedProductId = Rxn<String>();
  var selectedStatus = Rxn<String>();
  var followUpDate = Rxn<DateTime>();
  var productImageUrl = Rxn<String>();
  var productIdList = <String>[].obs;
  final statusList = ['HOT', 'WARM', 'COOL'].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs
          .map((doc) => doc.data()['id']?.toString() ?? doc.id)
          .toList();

      productIdList.assignAll(products);
      print('Fetched product IDs: $products');
    } catch (e) {
      Get.snackbar('Error', 'Error fetching products: $e');
    }
  }

  Future<void> fetchProductImage(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('id', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No document found for product ID: $productId');
        productImageUrl.value = null;
        return;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final imageUrl = data['imageUrl'] as String?;
      print('Fetched imageUrl for $productId: $imageUrl');

      productImageUrl.value = imageUrl;
    } catch (e) {
      print('Error fetching image for $productId: $e');
      productImageUrl.value = null;
      Get.snackbar('Error', 'Error loading image: $e');
    }
  }

  Future<void> saveLead() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please fill all required fields correctly');
      return;
    }

    if (followUpDate.value == null) {
      Get.snackbar('Error', 'Please select follow-up date');
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('id', isEqualTo: selectedProductId.value)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Selected product not found');
        return;
      }

      final productDocId = querySnapshot.docs.first.id;

      await _firestore.collection('Leads').add({
        'name': nameController.text,
        'place': placeController.text,
        'address': addressController.text,
        'phone1': phoneController.text,
        'phone2': phone2Controller.text.isNotEmpty
            ? phone2Controller.text
            : null,
        'productNo': productDocId,
        'nos': nosController.text,
        'remark': remarkController.text.isNotEmpty
            ? remarkController.text
            : null,
        'status': selectedStatus.value,
        'followUpDate': Timestamp.fromDate(followUpDate.value!),
        'createdAt': Timestamp.now(),
      });

      Get.snackbar('Success', 'Lead saved successfully');
      clearForm();
    } catch (e) {
      Get.snackbar('Error', 'Error saving lead: $e');
    }
  }

  Future<void> placeOrder() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please fill all required fields correctly');
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('id', isEqualTo: selectedProductId.value)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar('Error', 'Selected product not found');
        return;
      }

      final productDocId = querySnapshot.docs.first.id;

      await _firestore.collection('Orders').add({
        'name': nameController.text,
        'place': placeController.text,
        'address': addressController.text,
        'phone1': phoneController.text,
        'phone2': phone2Controller.text.isNotEmpty
            ? phone2Controller.text
            : null,
        'productNo': productDocId,
        'nos': nosController.text,
        'remark': remarkController.text.isNotEmpty
            ? remarkController.text
            : null,
        'status': selectedStatus.value,
        'followUpDate': followUpDate.value != null
            ? Timestamp.fromDate(followUpDate.value!)
            : null,
        'createdAt': Timestamp.now(),
      });

      Get.snackbar('Success', 'Order placed successfully');
      clearForm();
    } catch (e) {
      Get.snackbar('Error', 'Error placing order: $e');
    }
  }

  void clearForm() {
    nameController.clear();
    placeController.clear();
    addressController.clear();
    phoneController.clear();
    phone2Controller.clear();
    nosController.clear();
    remarkController.clear();
    selectedProductId.value = null;
    selectedStatus.value = null;
    followUpDate.value = null;
    productImageUrl.value = null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validatePlace(String? value) {
    if (value == null || value.isEmpty) return 'Place is required';
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Address is required';
    if (value.length < 5) return 'Address must be at least 5 characters';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value))
      return 'Enter valid 10-digit phone number';
    return null;
  }

  String? validatePhone2(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter valid 10-digit phone number';
    }
    return null;
  }

  String? validateNos(String? value) {
    if (value == null || value.isEmpty) return 'NOS is required';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Enter valid number';
    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    placeController.dispose();
    addressController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    nosController.dispose();
    remarkController.dispose();
    super.onClose();
  }
}
