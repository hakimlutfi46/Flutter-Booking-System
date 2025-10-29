import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';

void showAddSlotBottomSheet(
  BuildContext context,
  AvabilityController controller,
) {
  controller.resetForm();
  Get.bottomSheet(
    AddSlotBottomSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class AddSlotBottomSheet extends StatelessWidget {
  final AvabilityController controller;
  const AddSlotBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_alarm, color: Get.theme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tambah Jadwal Baru',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.resetForm();
                    Get.back();
                  },
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date picker tile
            Obx(
              () => _buildPickerTile(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal',
                valueText:
                    controller.selectedDate.value == null
                        ? 'Pilih tanggal'
                        : DateFormat(
                          'EEEE, d MMMM yyyy',
                          'id_ID',
                        ).format(controller.selectedDate.value!),
                onTap: () => _pickDate(context),
                isSelected: controller.selectedDate.value != null,
              ),
            ),

            // Start time
            Obx(
              () => _buildPickerTile(
                context: context,
                icon: Icons.access_time,
                label: 'Waktu Mulai',
                valueText:
                    controller.startTime.value == null
                        ? 'Pilih waktu mulai'
                        : controller.startTime.value!.format(context),
                onTap: () => _pickStartTime(context),
                isSelected: controller.startTime.value != null,
              ),
            ),

            // End time
            Obx(
              () => _buildPickerTile(
                context: context,
                icon: Icons.access_time_filled_outlined,
                label: 'Waktu Selesai',
                valueText:
                    controller.endTime.value == null
                        ? 'Pilih waktu selesai'
                        : controller.endTime.value!.format(context),
                onTap: () => _pickEndTime(context),
                isSelected: controller.endTime.value != null,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    controller.resetForm();
                    Get.back();
                  },
                  child: const Text('Batal'),
                ),
                Obx(
                  () => PrimaryButton(
                    text: 'Simpan Jadwal',
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      await controller.addSlot();
                      // Jika sudah selesai (success atau fail), close jika tidak loading
                      if (!controller.isLoading.value) {
                        await Future.delayed(Duration(milliseconds: 1500));
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String valueText,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? Get.theme.primaryColor.withOpacity(0.3)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Get.theme.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Get.theme.primaryColor : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          valueText,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isSelected ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  // Pickers
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Get.theme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) controller.selectedDate.value = picked;
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.startTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Get.theme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) controller.startTime.value = picked;
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.endTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Get.theme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) controller.endTime.value = picked;
  }
}
