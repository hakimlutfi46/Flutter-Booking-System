import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';

class AvailabilityScreen extends GetView<AvabilityController> {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Semua, Buka, Penuh
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          title: const Text(
            'Jadwal Ketersediaan',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.primary,
              child: TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_note_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text('Semua'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_available_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text('Buka'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text('Penuh'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddSlotDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Jadwal'),
          elevation: 2,
        ),
        body: Obx(() {
          if (controller.isLoading.value &&
              controller.availabilityList.isEmpty) {
            return const LoadingSpinner();
          }

          return TabBarView(
            children: [
              // Tab Semua
              _buildScheduleList(context, 'all'),
              // Tab Buka
              _buildScheduleList(context, 'open'),
              // Tab Penuh
              _buildScheduleList(context, 'closed'),
            ],
          );
        }),
      ),
    );
  }

  // Build list berdasarkan filter status
  Widget _buildScheduleList(BuildContext context, String filter) {
    // Filter data berdasarkan status
    final filteredList =
        filter == 'all'
            ? controller.availabilityList
            : controller.availabilityList
                .where((slot) => slot.status == filter)
                .toList();

    if (filteredList.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (BuildContext context, int index) {
        final slot = filteredList[index];
        final bool isOpen = slot.status == 'open';

        return Dismissible(
          key: Key('${slot.uid}_$filter'),
          direction:
              isOpen ? DismissDirection.endToStart : DismissDirection.none,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16.0),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Colors.white, size: 28),
                const SizedBox(height: 4),
                Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
  }

  // Empty state untuk setiap tab
  Widget _buildEmptyState(String filter) {
    String title;
    String message;
    IconData icon;

    switch (filter) {
      case 'open':
        title = 'Tidak Ada Jadwal Buka';
        message =
            'Semua jadwal Anda sudah terisi penuh atau belum ada jadwal yang ditambahkan';
        icon = Icons.event_available_outlined;
        break;
      case 'closed':
        title = 'Tidak Ada Jadwal Penuh';
        message =
            'Belum ada jadwal yang terisi penuh. Semua slot masih tersedia!';
        icon = Icons.event_busy_outlined;
        break;
      default:
        title = 'Belum Ada Jadwal';
        message =
            'Tambahkan jadwal ketersediaan Anda untuk mulai menerima booking';
        icon = Icons.event_note_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // Custom card dengan chip di pojok kanan bawah
  Widget _buildScheduleCard(BuildContext context, dynamic slot, bool isOpen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSlotDetail(context, slot),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan icon dan waktu
                Row(
                  children: [
                    // Icon dengan gradient background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (isOpen
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600)
                                .withOpacity(0.15),
                            (isOpen
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600)
                                .withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        isOpen
                            ? Icons.event_available_outlined
                            : Icons.event_busy_outlined,
                        color:
                            isOpen
                                ? Colors.green.shade600
                                : Colors.orange.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Waktu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.formatLocalTime(slot.startUTC),
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selesai: ${DateFormat('HH:mm').format(slot.endUTC.toLocal())}',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Informasi kapasitas dan chip status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info kapasitas
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kapasitas: ${slot.capacity ?? 1} orang',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    // Chip status di pojok kanan bawah
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOpen
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isOpen
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isOpen ? 'BUKA' : 'PENUH',
                        style: TextStyle(
                          color:
                              isOpen
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
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
  void _showSlotDetail(BuildContext context, dynamic slot) {
    final bool isOpen = slot.status == 'open';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isOpen ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isOpen ? Icons.event_available : Icons.event_busy,
                      color:
                          isOpen
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Jadwal',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOpen ? 'Slot Tersedia' : 'Slot Penuh',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Detail info
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Tanggal',
                DateFormat('EEEE, d MMMM yyyy').format(slot.startUTC.toLocal()),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.access_time,
                'Waktu',
                '${DateFormat('HH:mm').format(slot.startUTC.toLocal())} - ${DateFormat('HH:mm').format(slot.endUTC.toLocal())}',
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.people_outline,
                'Kapasitas',
                '${slot.capacity ?? 1} orang',
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.info_outline,
                'Status',
                isOpen ? 'Tersedia untuk booking' : 'Sudah terisi penuh',
              ),

              const SizedBox(height: 24),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                  if (isOpen) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _showDeleteConfirmation(context, slot.uid);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Hapus'),
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
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
    BuildContext context,
    String slotId,
  ) async {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Jadwal?'),
          ],
        ),
        content: const Text(
          'Jadwal yang dihapus tidak dapat dikembalikan. Apakah Anda yakin?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back(result: true);
              controller.removeSlot(slotId);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // BottomSheet untuk Menambah Slot Baru
  void _showAddSlotDialog(BuildContext context) {
    controller.selectedDate.value = null;
    controller.startTime.value = null;
    controller.endTime.value = null;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
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
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form inputs
              Obx(
                () => _buildDateTimePickerTile(
                  context: context,
                  icon: Icons.calendar_today_outlined,
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

              Obx(
                () => _buildDateTimePickerTile(
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: true,
    );
  }

  // Helper widget untuk picker tile
  Widget _buildDateTimePickerTile({
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

  // Date/Time Pickers
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
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

  Future<void> _pickEndTime(BuildContext context) async {
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
    if (picked != null) controller.endTime.value = picked;
  }
}
