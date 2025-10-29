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
}
