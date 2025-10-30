import 'package:flutter/material.dart';

class StatusInfo {
  final IconData icon;
  final String label;
  final Color color;

  StatusInfo({required this.icon, required this.label, required this.color});

  static StatusInfo fromStatus(String status) {
    switch (status) {
      case 'confirmed':
        return StatusInfo(
          icon: Icons.check_circle_outline,
          label: 'CONFIRMED',
          color: Colors.green.shade600,
        );
      case 'cancelled':
        return StatusInfo(
          icon: Icons.cancel_outlined,
          label: 'CANCELLED',
          color: Colors.red.shade600,
        );
      case 'completed':
        return StatusInfo(
          icon: Icons.task_alt_outlined,
          label: 'COMPLETED',
          color: Colors.blue.shade600,
        );
      case 'noShow':
        return StatusInfo(
          icon: Icons.highlight_off,
          label: 'NO SHOW',
          color: Colors.orange.shade600,
        );
      default:
        return StatusInfo(
          icon: Icons.help_outline,
          label: 'UNKNOWN',
          color: Colors.grey.shade600,
        );
    }
  }
}
