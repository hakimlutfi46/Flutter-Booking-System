import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:flutter_booking_system/presentation/widgets/slot_detail_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AvailabilityCard extends GetView<AvabilityController> {
  final dynamic slot;
  const AvailabilityCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final bool isOpen = slot.status == 'open';

    return Dismissible(
      key: Key(slot.uid),
      direction: isOpen ? DismissDirection.endToStart : DismissDirection.none,
      background: _buildDismissBg(),
      confirmDismiss:
          (_) async => await controller.showDeleteConfirmation(slot.uid),
      child: InkWell(
        onTap: () => showSlotDetailDialog(context, slot),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildCardContent(context, isOpen),
        ),
      ),
    );
  }

  Widget _buildDismissBg() => Container(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    decoration: BoxDecoration(
      color: Colors.red.shade400,
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
  );

  Widget _buildCardContent(BuildContext context, bool isOpen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isOpen ? Icons.event_available : Icons.event_busy,
              color: isOpen ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(slot.startUTC.toLocal()),
                    style: Get.textTheme.titleMedium,
                  ),
                  Text(
                    '${DateFormat('HH.mm').format(slot.startUTC.toLocal())} - ${DateFormat('HH.mm').format(slot.endUTC.toLocal())}',
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kapasitas: ${slot.capacity ?? 1} orang',
              style: Get.textTheme.bodyMedium,
            ),
            Chip(
              label: Text(
                isOpen ? 'Buka' : 'Penuh',
                style: Get.textTheme.bodySmall,
              ),
              backgroundColor:
                  isOpen ? Colors.green.shade100 : Colors.amber.shade100,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
