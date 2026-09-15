class DateFormatter {
  static const List<String> _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  static const List<String> _fullMonths = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  static const List<String> _weekdays = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  static String formatFullDate(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _fullMonths[date.month - 1];
    return '$weekday, ${date.day} de $month de ${date.year}';
  }

  static String formatShortDate(DateTime date) {
    final month = _months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  static String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      final month = _months[date.month - 1];
      return '${date.day} $month';
    } else if (difference.inDays >= 1) {
      return 'Hace ${difference.inDays} día${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours >= 1) {
      return 'Hace ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes >= 1) {
      return 'Hace ${difference.inMinutes} min';
    } else {
      return 'Hace un momento';
    }
  }
}
