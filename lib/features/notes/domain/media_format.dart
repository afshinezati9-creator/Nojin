abstract final class MediaFormat {
  static String size(int bytes) {
    if (bytes < 1024) return '$bytes بایت';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.round()} کیلوبایت';
    final mb = kb / 1024;
    return '${(mb * 10).round() / 10} مگابایت';
  }

  static String duration(int? milliseconds) {
    if (milliseconds == null || milliseconds < 0) return '';
    final total = (milliseconds / 1000).round();
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
