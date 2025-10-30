import 'package:intl/intl.dart';

class FormatterUtils {
  /// Format hanya jam dan menit lokal, misalnya: "13:45"
  static String formatTimeOnly(DateTime dateTime) {
    try {
      // Pastikan dateTime diubah ke waktu lokal agar sesuai zona pengguna
      final localTime = dateTime.toLocal();
      return DateFormat('HH:mm').format(localTime);
    } catch (e) {
      // Jika parsing gagal, kembalikan string kosong
      return '-';
    }
  }

  /// Format tanggal lengkap (contoh tambahan)
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dateTime.toLocal());
  }

  /// Format rentang waktu, misalnya "13:00 - 14:30"
  static String formatTimeRange(DateTime start, DateTime end) {
    return "${formatTimeOnly(start)} - ${formatTimeOnly(end)}";
  }

  static String formatDateRelative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) return 'Hari ini';
    if (difference == 1) return 'Besok';
    if (difference == -1) return 'Kemarin';

    return DateFormat('EEEE', 'id_ID').format(dateTime.toLocal());
  }

  static String formatBookingTime(DateTime startUTC, DateTime endUTC) {
    final startLocal = startUTC.toLocal();
    final endLocal = endUTC.toLocal();
    final dateString = DateFormat(
      'EEE, d MMM yyyy',
      'id_ID',
    ).format(startLocal);
    final timeString =
        '${DateFormat('HH:mm').format(startLocal)} - ${DateFormat('HH:mm').format(endLocal)}';
    return '$dateString\n$timeString';
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  static String getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }

  // Helper: Get role name
  static String getRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return 'Parent';
      case 'tutor':
        return 'Tutor';
      default:
        return role[0].toUpperCase() + role.substring(1);
    }
  }
}
