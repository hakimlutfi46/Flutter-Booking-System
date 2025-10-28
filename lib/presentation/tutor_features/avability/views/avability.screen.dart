import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';
import 'package:flutter_booking_system/presentation/widgets/info_card.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';

class AvailabilityScreen extends GetView<AvabilityController> {
  const AvailabilityScreen({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    return material.Scaffold(
      backgroundColor: material.Colors.grey.shade50,
      appBar: material.AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const material.Text(
          'Jadwal Ketersediaan',
          style: material.TextStyle(
            fontWeight: material.FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      floatingActionButton: material.FloatingActionButton.extended(
        onPressed: () => _showAddSlotDialog(context),
        icon: const material.Icon(material.Icons.add),
        label: const material.Text('Tambah Jadwal'),
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.availabilityList.isEmpty) {
          return const LoadingSpinner();
        }

        if (controller.availabilityList.isEmpty) {
          return material.Center(
            child: material.Column(
              mainAxisAlignment: material.MainAxisAlignment.center,
              children: [
                material.Icon(
                  material.Icons.event_busy_outlined,
                  size: 80,
                  color: material.Colors.grey.shade300,
                ),
                const material.SizedBox(height: 16),
                material.Text(
                  'Belum Ada Jadwal',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: material.FontWeight.w600,
                    color: material.Colors.grey.shade700,
                  ),
                ),
                const material.SizedBox(height: 8),
                material.Padding(
                  padding: const material.EdgeInsets.symmetric(horizontal: 48),
                  child: material.Text(
                    'Tambahkan jadwal ketersediaan Anda untuk mulai menerima booking',
                    textAlign: material.TextAlign.center,
                    style: material.TextStyle(
                      color: material.Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return material.ListView.builder(
          padding: const material.EdgeInsets.all(16),
          itemCount: controller.availabilityList.length,
          itemBuilder: (material.BuildContext context, int index) {
            final slot = controller.availabilityList[index];
            final bool isOpen = slot.status == 'open';

            return material.Dismissible(
              key: material.Key(slot.uid),
              direction:
                  isOpen
                      ? material.DismissDirection.endToStart
                      : material.DismissDirection.none,
              background: material.Container(
                margin: const material.EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 4.0,
                ),
                decoration: material.BoxDecoration(
                  color: material.Colors.red.shade400,
                  borderRadius: material.BorderRadius.circular(16.0),
                ),
                alignment: material.Alignment.centerRight,
                padding: const material.EdgeInsets.only(right: 24),
                child: material.Column(
                  mainAxisAlignment: material.MainAxisAlignment.center,
                  children: [
                    material.Icon(
                      material.Icons.delete_outline,
                      color: material.Colors.white,
                      size: 28,
                    ),
                    const material.SizedBox(height: 4),
                    material.Text(
                      'Hapus',
                      style: material.TextStyle(
                        color: material.Colors.white,
                        fontWeight: material.FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmation(context, slot.uid);
              },
              child: _buildScheduleCard(context, slot, isOpen),
            );
          },
        );
      }),
    );
  }

  // Custom card dengan chip di pojok kanan bawah
  material.Widget _buildScheduleCard(
    material.BuildContext context,
    dynamic slot,
    bool isOpen,
  ) {
    return material.Container(
      margin: const material.EdgeInsets.symmetric(
        vertical: 6.0,
        horizontal: 4.0,
      ),
      decoration: material.BoxDecoration(
        color: material.Colors.white,
        borderRadius: material.BorderRadius.circular(16.0),
        boxShadow: [
          material.BoxShadow(
            color: material.Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const material.Offset(0, 2),
          ),
        ],
      ),
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          onTap: () => _showSlotDetail(context, slot),
          borderRadius: material.BorderRadius.circular(16.0),
          child: material.Padding(
            padding: const material.EdgeInsets.all(16.0),
            child: material.Column(
              crossAxisAlignment: material.CrossAxisAlignment.start,
              children: [
                // Header dengan icon dan waktu
                material.Row(
                  children: [
                    // Icon dengan gradient background
                    material.Container(
                      width: 48,
                      height: 48,
                      decoration: material.BoxDecoration(
                        gradient: material.LinearGradient(
                          colors: [
                            (isOpen
                                    ? material.Colors.green.shade600
                                    : material.Colors.orange.shade600)
                                .withOpacity(0.15),
                            (isOpen
                                    ? material.Colors.green.shade600
                                    : material.Colors.orange.shade600)
                                .withOpacity(0.05),
                          ],
                          begin: material.Alignment.topLeft,
                          end: material.Alignment.bottomRight,
                        ),
                        borderRadius: material.BorderRadius.circular(12.0),
                      ),
                      child: material.Icon(
                        isOpen
                            ? material.Icons.event_available_outlined
                            : material.Icons.event_busy_outlined,
                        color:
                            isOpen
                                ? material.Colors.green.shade600
                                : material.Colors.orange.shade600,
                        size: 24,
                      ),
                    ),
                    const material.SizedBox(width: 16),

                    // Waktu
                    material.Expanded(
                      child: material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          material.Text(
                            controller.formatLocalTime(slot.startUTC),
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: material.FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const material.SizedBox(height: 4),
                          material.Text(
                            'Selesai: ${DateFormat('HH:mm').format(slot.endUTC.toLocal())}',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: material.Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const material.SizedBox(height: 12),

                // Informasi kapasitas dan chip status
                material.Row(
                  mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                  children: [
                    // Info kapasitas
                    material.Row(
                      children: [
                        material.Icon(
                          material.Icons.people_outline,
                          size: 16,
                          color: material.Colors.grey.shade600,
                        ),
                        const material.SizedBox(width: 6),
                        material.Text(
                          'Kapasitas: ${slot.capacity ?? 1} orang',
                          style: material.TextStyle(
                            color: material.Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    // Chip status di pojok kanan bawah
                    material.Container(
                      padding: const material.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: material.BoxDecoration(
                        color:
                            isOpen
                                ? material.Colors.green.shade50
                                : material.Colors.orange.shade50,
                        borderRadius: material.BorderRadius.circular(20),
                        border: material.Border.all(
                          color:
                              isOpen
                                  ? material.Colors.green.shade200
                                  : material.Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: material.Text(
                        isOpen ? 'BUKA' : 'PENUH',
                        style: material.TextStyle(
                          color:
                              isOpen
                                  ? material.Colors.green.shade700
                                  : material.Colors.orange.shade700,
                          fontWeight: material.FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog Detail Slot
  void _showSlotDetail(material.BuildContext context, dynamic slot) {
    final bool isOpen = slot.status == 'open';

    Get.dialog(
      material.Dialog(
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.circular(20),
        ),
        child: material.Container(
          padding: const material.EdgeInsets.all(24),
          child: material.Column(
            mainAxisSize: material.MainAxisSize.min,
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              // Header dengan icon
              material.Row(
                children: [
                  material.Container(
                    padding: const material.EdgeInsets.all(12),
                    decoration: material.BoxDecoration(
                      color:
                          isOpen
                              ? material.Colors.green.shade50
                              : material.Colors.orange.shade50,
                      borderRadius: material.BorderRadius.circular(12),
                    ),
                    child: material.Icon(
                      isOpen
                          ? material.Icons.event_available
                          : material.Icons.event_busy,
                      color:
                          isOpen
                              ? material.Colors.green.shade600
                              : material.Colors.orange.shade600,
                      size: 28,
                    ),
                  ),
                  const material.SizedBox(width: 16),
                  material.Expanded(
                    child: material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Text(
                          'Detail Jadwal',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: material.FontWeight.bold,
                          ),
                        ),
                        material.Text(
                          isOpen ? 'Slot Tersedia' : 'Slot Penuh',
                          style: material.TextStyle(
                            color: material.Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const material.SizedBox(height: 24),

              // Detail info
              _buildDetailRow(
                material.Icons.calendar_today_outlined,
                'Tanggal',
                DateFormat('EEEE, d MMMM yyyy').format(slot.startUTC.toLocal()),
              ),
              const material.SizedBox(height: 16),
              _buildDetailRow(
                material.Icons.access_time,
                'Waktu',
                '${DateFormat('HH:mm').format(slot.startUTC.toLocal())} - ${DateFormat('HH:mm').format(slot.endUTC.toLocal())}',
              ),
              const material.SizedBox(height: 16),
              _buildDetailRow(
                material.Icons.people_outline,
                'Kapasitas',
                '${slot.capacity ?? 1} orang',
              ),
              const material.SizedBox(height: 16),
              _buildDetailRow(
                material.Icons.info_outline,
                'Status',
                isOpen ? 'Tersedia untuk booking' : 'Sudah terisi penuh',
              ),

              const material.SizedBox(height: 24),

              // Tombol aksi
              material.Row(
                children: [
                  material.Expanded(
                    child: material.OutlinedButton(
                      onPressed: () => Get.back(),
                      style: material.OutlinedButton.styleFrom(
                        padding: const material.EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: material.RoundedRectangleBorder(
                          borderRadius: material.BorderRadius.circular(12),
                        ),
                      ),
                      child: const material.Text('Tutup'),
                    ),
                  ),
                  if (isOpen) ...[
                    const material.SizedBox(width: 12),
                    material.Expanded(
                      child: material.ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _showDeleteConfirmation(context, slot.uid);
                        },
                        style: material.ElevatedButton.styleFrom(
                          backgroundColor: material.Colors.red.shade600,
                          foregroundColor: material.Colors.white,
                          padding: const material.EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: material.RoundedRectangleBorder(
                            borderRadius: material.BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const material.Text('Hapus'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk detail row
  material.Widget _buildDetailRow(
    material.IconData icon,
    String label,
    String value,
  ) {
    return material.Row(
      crossAxisAlignment: material.CrossAxisAlignment.start,
      children: [
        material.Icon(icon, size: 20, color: material.Colors.grey.shade600),
        const material.SizedBox(width: 12),
        material.Expanded(
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Text(
                label,
                style: material.TextStyle(
                  color: material.Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: material.FontWeight.w500,
                ),
              ),
              const material.SizedBox(height: 2),
              material.Text(
                value,
                style: const material.TextStyle(
                  fontSize: 15,
                  fontWeight: material.FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dialog Konfirmasi Hapus
  Future<bool?> _showDeleteConfirmation(
    material.BuildContext context,
    String slotId,
  ) async {
    return Get.dialog<bool>(
      material.AlertDialog(
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.circular(16),
        ),
        title: material.Row(
          children: [
            material.Container(
              padding: const material.EdgeInsets.all(8),
              decoration: material.BoxDecoration(
                color: material.Colors.red.shade50,
                borderRadius: material.BorderRadius.circular(8),
              ),
              child: material.Icon(
                material.Icons.delete_outline,
                color: material.Colors.red.shade600,
                size: 24,
              ),
            ),
            const material.SizedBox(width: 12),
            const material.Text('Hapus Jadwal?'),
          ],
        ),
        content: const material.Text(
          'Jadwal yang dihapus tidak dapat dikembalikan. Apakah Anda yakin?',
          style: material.TextStyle(height: 1.5),
        ),
        actions: [
          material.TextButton(
            onPressed: () => Get.back(result: false),
            child: const material.Text('Batal'),
          ),
          material.ElevatedButton(
            style: material.ElevatedButton.styleFrom(
              backgroundColor: material.Colors.red.shade600,
              foregroundColor: material.Colors.white,
              elevation: 0,
              shape: material.RoundedRectangleBorder(
                borderRadius: material.BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back(result: true);
              controller.removeSlot(slotId);
            },
            child: const material.Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // BottomSheet untuk Menambah Slot Baru
  void _showAddSlotDialog(material.BuildContext context) {
    controller.selectedDate.value = null;
    controller.startTime.value = null;
    controller.endTime.value = null;

    Get.bottomSheet(
      isScrollControlled: true,
      material.Container(
        padding: material.EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: material.MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: material.BoxDecoration(
          color: material.Colors.white,
          borderRadius: const material.BorderRadius.vertical(
            top: material.Radius.circular(24),
          ),
        ),
        child: material.SingleChildScrollView(
          child: material.Column(
            mainAxisSize: material.MainAxisSize.min,
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              // Header
              material.Row(
                children: [
                  material.Container(
                    padding: const material.EdgeInsets.all(10),
                    decoration: material.BoxDecoration(
                      color: Get.theme.primaryColor.withOpacity(0.1),
                      borderRadius: material.BorderRadius.circular(12),
                    ),
                    child: material.Icon(
                      material.Icons.add_alarm,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  const material.SizedBox(width: 12),
                  material.Expanded(
                    child: material.Text(
                      'Tambah Jadwal Baru',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: material.FontWeight.bold,
                      ),
                    ),
                  ),
                  material.IconButton(
                    onPressed: () => Get.back(),
                    icon: const material.Icon(material.Icons.close),
                    style: material.IconButton.styleFrom(
                      backgroundColor: material.Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const material.SizedBox(height: 24),

              // Form inputs
              Obx(
                () => _buildDateTimePickerTile(
                  context: context,
                  icon: material.Icons.calendar_today_outlined,
                  label: 'Tanggal',
                  valueText:
                      controller.selectedDate.value == null
                          ? 'Pilih tanggal'
                          : DateFormat(
                            'EEEE, d MMMM yyyy',
                          ).format(controller.selectedDate.value!),
                  onTap: () => _pickDate(context),
                  isSelected: controller.selectedDate.value != null,
                ),
              ),

              Obx(
                () => _buildDateTimePickerTile(
                  context: context,
                  icon: material.Icons.access_time,
                  label: 'Waktu Mulai',
                  valueText:
                      controller.startTime.value == null
                          ? 'Pilih waktu mulai'
                          : controller.startTime.value!.format(context),
                  onTap: () => _pickStartTime(context),
                  isSelected: controller.startTime.value != null,
                ),
              ),

              Obx(
                () => _buildDateTimePickerTile(
                  context: context,
                  icon: material.Icons.access_time_filled_outlined,
                  label: 'Waktu Selesai',
                  valueText:
                      controller.endTime.value == null
                          ? 'Pilih waktu selesai'
                          : controller.endTime.value!.format(context),
                  onTap: () => _pickEndTime(context),
                  isSelected: controller.endTime.value != null,
                ),
              ),

              const material.SizedBox(height: 24),

              // Tombol Simpan
              Obx(
                () => PrimaryButton(
                  text: 'Simpan Jadwal',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    controller.addSlot().then((_) {
                      if (!controller.isLoading.value) {
                        Get.back();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: material.Colors.transparent,
      elevation: 0,
      isDismissible: true,
    );
  }

  // Helper widget untuk picker tile
  material.Widget _buildDateTimePickerTile({
    required material.BuildContext context,
    required material.IconData icon,
    required String label,
    required String valueText,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return material.Container(
      margin: const material.EdgeInsets.only(bottom: 12),
      decoration: material.BoxDecoration(
        color: material.Colors.grey.shade50,
        borderRadius: material.BorderRadius.circular(12),
        border: material.Border.all(
          color:
              isSelected
                  ? Get.theme.primaryColor.withOpacity(0.3)
                  : material.Colors.transparent,
          width: 1.5,
        ),
      ),
      child: material.ListTile(
        contentPadding: const material.EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: material.Container(
          padding: const material.EdgeInsets.all(8),
          decoration: material.BoxDecoration(
            color:
                isSelected
                    ? Get.theme.primaryColor.withOpacity(0.1)
                    : material.Colors.grey.shade200,
            borderRadius: material.BorderRadius.circular(8),
          ),
          child: material.Icon(
            icon,
            color:
                isSelected
                    ? Get.theme.primaryColor
                    : material.Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: material.Text(
          label,
          style: material.TextStyle(
            fontSize: 12,
            color: material.Colors.grey.shade600,
            fontWeight: material.FontWeight.w500,
          ),
        ),
        subtitle: material.Text(
          valueText,
          style: material.TextStyle(
            fontWeight: material.FontWeight.w600,
            fontSize: 15,
            color:
                isSelected
                    ? material.Colors.black87
                    : material.Colors.grey.shade500,
          ),
        ),
        trailing: material.Icon(
          material.Icons.chevron_right,
          color: material.Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  // Date/Time Pickers
  Future<void> _pickDate(material.BuildContext context) async {
    final DateTime? picked = await material.showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  Future<void> _pickStartTime(material.BuildContext context) async {
    final TimeOfDay? picked = await material.showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  Future<void> _pickEndTime(material.BuildContext context) async {
    final TimeOfDay? picked = await material.showTimePicker(
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
    if (picked != null) controller.endTime.value = picked;
  }
}
