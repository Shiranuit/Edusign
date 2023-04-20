class BoolHelper {
  static bool parse(dynamic value) {
    if (value is String) {
      return value.toLowerCase() == 'true';
    } else if (value is bool) {
      return value;
    } else {
      return false;
    }
  }
}
