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
  var productStockMap = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final products = <String>[];
      final stockMap = <String, int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final id = data['id']?.toString() ?? doc.id;
        final stock = data['stock'] is int ? data['stock'] : 0;
        products.add(id);
        stockMap[id] = stock;
      }

      productIdList.assignAll(products);
      productStockMap.assignAll(stockMap);

      print('Fetched product IDs: $products');
      print('Fetched product stock: $stockMap');
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
        productImageUrl.value = null;
        return;
      }

      final data = querySnapshot.docs.first.data();
      final imageUrl = data['imageUrl']?.toString();
      productImageUrl.value = imageUrl;
    } catch (e) {
      productImageUrl.value = null;
      Get.snackbar('Error', 'Error loading image: $e');
    }
  }

  Future<String> generateFormattedId({
    required String collectionName,
    required String prefix,
  }) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    int lastNumber = 0;

    if (snapshot.docs.isNotEmpty) {
      final lastIdRaw = snapshot.docs.first.data()['customId'];
      if (lastIdRaw != null && lastIdRaw is String) {
        final digits = RegExp(r'\d+').firstMatch(lastIdRaw)?.group(0);
        lastNumber = int.tryParse(digits ?? '0') ?? 0;
      }
    }

    final newNumber = lastNumber + 1;
    return '$prefix-${newNumber.toString().padLeft(5, '0')}';
  }

  Future<String> _generateCustomOrderId() async {
    final snapshot = await _firestore
        .collection('Orders')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    int lastNumber = 0;

    if (snapshot.docs.isNotEmpty) {
      final lastIdRaw = snapshot.docs.first.data()['orderId'];
      if (lastIdRaw != null && lastIdRaw is String) {
        final digits = RegExp(r'\d+').firstMatch(lastIdRaw)?.group(0);
        lastNumber = int.tryParse(digits ?? '0') ?? 0;
      }
    }

    final newNumber = lastNumber + 1;
    return 'ORD${newNumber.toString().padLeft(5, '0')}';
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
      final leadId = await generateFormattedId(
        collectionName: 'Leads',
        prefix: 'LEA',
      );

      await _firestore.collection('Leads').add({
        'customId': leadId,
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
      final newOrderId = await _generateCustomOrderId();

      await _firestore.collection('Orders').add({
        'orderId': newOrderId,
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
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter valid 10-digit phone number';
    }
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

    final enteredNos = int.tryParse(value);
    final selectedProductId = this.selectedProductId.value;
    final availableStock = productStockMap[selectedProductId] ?? 0;

    if (enteredNos != null && enteredNos > availableStock) {
      return 'Only $availableStock in stock';
    }

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
