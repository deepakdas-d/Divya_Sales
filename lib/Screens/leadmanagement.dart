import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales/Lead_Management/controller/lead_management_controller.dart';

class LeadManagement extends StatelessWidget {
  const LeadManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeadManagementController());
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3B82F6),
        title: const Center(
          child: Text(
            "Lead Management",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel("Name:", screenHeight),
              buildTextField(
                "Name",
                controller: controller.nameController,
                validator: controller.validateName,
              ),

              buildLabel("Place:", screenHeight),
              buildTextField(
                "Place",
                controller: controller.placeController,
                validator: controller.validatePlace,
              ),

              buildLabel("Address:", screenHeight),
              buildTextField(
                "Address",
                controller: controller.addressController,
                validator: controller.validateAddress,
              ),

              buildLabel("Phone 1:", screenHeight),
              buildTextField(
                "Phone",
                controller: controller.phoneController,
                validator: controller.validatePhone,
              ),

              buildLabel("Phone 2 (Optional):", screenHeight),
              buildTextField(
                "Phone",
                controller: controller.phone2Controller,
                validator: controller.validatePhone2,
              ),

              buildLabel("Product ID:", screenHeight),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedProductId.value,
                    hint: const Text("Select Product"),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          "-- Select --",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...controller.productIdList.map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      ),
                    ],
                    onChanged: (value) {
                      controller.selectedProductId.value = value;
                      if (value != null) {
                        controller.fetchProductImage(value);
                      } else {
                        controller.productImageUrl.value = null;
                      }
                    },
                    decoration: dropdownDecoration(),
                    validator: (value) =>
                        value == null ? 'Product is required' : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Obx(
                  () => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: controller.productImageUrl.value ?? '',
                      width: screenHeight * 0.3,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Obx(() {
                final productId = controller.selectedProductId.value;
                if (productId == null) return const SizedBox();

                return buildStockStatus(
                  productId,
                  MediaQuery.of(context).size.height,
                );
              }),

              buildLabel("NOS:", screenHeight),
              buildTextFieldForNumber(
                "Enter NOS",
                controller: controller.nosController,
                validator: controller.validateNos,
              ),

              buildLabel("Remark (Optional):", screenHeight),
              buildTextField(
                "Enter Remark",
                controller: controller.remarkController,
              ),

              buildLabel("Status:", screenHeight),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,
                    hint: const Text("Select Status"),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          "-- Select --",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...controller.statusList.map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.selectedStatus.value = value,
                    decoration: dropdownDecoration(),
                    validator: (value) =>
                        value == null ? 'Status is required' : null,
                  ),
                ),
              ),

              buildLabel("Follow Up Date:", screenHeight),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.followUpDate.value ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        controller.followUpDate.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E5F2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.followUpDate.value == null
                                ? "Select Date"
                                : DateFormat(
                                    'dd-MM-yyyy',
                                  ).format(controller.followUpDate.value!),
                            style: const TextStyle(color: Colors.black87),
                          ),
                          if (controller.followUpDate.value != null)
                            GestureDetector(
                              onTap: () => controller.followUpDate.value = null,
                              child: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: controller.saveLead,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Text("Save"),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: controller.placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Text("Order Now"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStockStatus(String productId, double screenHeight) {
    final controller = Get.find<LeadManagementController>();
    final stock = controller.productStockMap[productId] ?? 0;

    String statusText;
    Color statusColor;

    if (stock > 10) {
      statusText = '$stock in Stock ';
      statusColor = Colors.green;
    } else if (stock > 0) {
      statusText = 'Only $stock left!';
      statusColor = Colors.orange;
    } else {
      statusText = 'Out of Stock';
      statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8),
      child: Row(
        children: [
          Icon(Icons.inventory, color: statusColor, size: screenHeight * 0.025),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: screenHeight * 0.021,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenHeight * 0.021,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF003D68),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label, {
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          label: Text(label),
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 193, 204, 240),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.transparent, width: 2),
          ),
          fillColor: const Color(0xFFE1E5F2),
          filled: true,
        ),
      ),
    );
  }

  InputDecoration dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.transparent, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFE1E5F2),
    );
  }
}

Widget buildTextFieldForNumber(
  String label, {
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      keyboardType: TextInputType.number,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        label: Text(label),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 193, 204, 240)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        fillColor: const Color(0xFFE1E5F2),
        filled: true,
      ),
    ),
  );
}
