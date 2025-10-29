import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';

Future<void> showSlotDetailDialog(BuildContext context, dynamic slot) async {
  final AvabilityController controller = Get.find<AvabilityController>();
  final bool isOpen = slot.status == 'open';

  await Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                        isOpen ? Colors.green.shade600 : Colors.orange.shade600,
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

            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Tanggal',
              DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(slot.startUTC.toLocal()),
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

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
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
                      onPressed: () async {
                        // Jadikan async
                        // Get.back(); <-- HAPUS BARIS INI (Jangan tutup detail dulu)

                        // Panggil konfirmasi dan TUNGGU hasilnya
                        final bool confirmed = await controller
                            .showDeleteConfirmation(slot.uid);

                        // JIKA user mengkonfirmasi Hapus (result == true),
                        // BARU tutup dialog detail ini.
                        if (confirmed == true && Get.isDialogOpen == true) {
                          // Cek juga dialognya masih ada
                          Get.back(); // Tutup dialog detail slot
                        }
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
