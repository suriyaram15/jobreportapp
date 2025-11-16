// =================== lib/utils/time_utils.dart ===================
class TimeUtils {
  static String format(Duration d) {
    return "${d.inHours}h ${(d.inMinutes % 60)}m";
  }
}