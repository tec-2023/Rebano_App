import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/financial_transaction.dart';

class ExportService {
  /// Genera y comparte el archivo CSV/Excel con el historial financiero
  static Future<bool> exportTransactionsToCsv({
    required List<FinancialTransaction> transactions,
    required String churchName,
  }) async {
    try {
      final List<List<dynamic>> rows = [];

      // Encabezado del documento
      rows.add(['REPORTE FINANCIERO - REBAÑO APP']);
      rows.add(['Congregación:', churchName]);
      rows.add(['Fecha de Emisión:', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())]);
      rows.add([]); // Espacio

      // Encabezados de columnas
      rows.add([
        'ID Transacción',
        'Fecha',
        'Tipo',
        'Categoría',
        'Monto (C\$ Córdobas)',
        'Donante / Beneficiario',
        'Descripción',
        'Tiene Comprobante / Recibo',
        'Registrado Por',
      ]);

      // Filas de datos
      for (var tx in transactions) {
        rows.add([
          tx.id,
          DateFormat('yyyy-MM-dd').format(tx.date),
          tx.type == TransactionType.income ? 'INGRESO' : 'EGRESO',
          tx.category,
          tx.amount.toStringAsFixed(2),
          tx.donorOrRecipient ?? 'N/A',
          tx.description,
          tx.hasReceipt ? 'SÍ' : 'NO',
          tx.registeredBy,
        ]);
      }

      // Convertir a formato CSV
      final csvString = const ListToCsvConverter().convert(rows);

      // Guardar en archivo temporal
      final directory = await getTemporaryDirectory();
      final sanitizedName = churchName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final fileName = 'Reporte_Tesoreria_${sanitizedName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);

      // Compartir archivo usando share_plus
      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Reporte de Tesorería - $churchName',
        text: 'Adjunto el reporte financiero de $churchName generado desde Rebaño App.',
      );

      return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (e) {
      return false;
    }
  }
}
