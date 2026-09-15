import 'dart:math';

class CodeGenerator {
  /// Genera un código de iglesia único con formato REB-XXXX
  static String generateChurchCode() {
    final random = Random();
    final number = 1000 + random.nextInt(9000);
    return 'REB-$number';
  }
}
