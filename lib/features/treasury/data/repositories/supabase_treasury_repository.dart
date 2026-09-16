import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/financial_transaction.dart';
import 'mock_treasury_repository.dart';

class SupabaseTreasuryRepository implements TreasuryRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<List<FinancialTransaction>> getTransactions(String churchId) async {
    try {
      final List<dynamic> response = await _client
          .from('transacciones_financieras')
          .select()
          .eq('id_iglesia', churchId)
          .order('fecha', ascending: false);

      return response.map((data) => _mapToTransaction(data)).toList();
    } catch (e) {
      debugPrint('[SupabaseTreasuryRepository] Error al obtener transacciones: $e');
      return [];
    }
  }

  @override
  Future<FinancialSummary> getFinancialSummary(String churchId) async {
    try {
      final transactions = await getTransactions(churchId);

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      for (var tx in transactions) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      return FinancialSummary(
        currentBalance: totalIncome - totalExpense,
        monthlyIncome: totalIncome,
        monthlyExpenses: totalExpense,
      );
    } catch (e) {
      debugPrint('[SupabaseTreasuryRepository] Error al calcular resumen financiero: $e');
      return const FinancialSummary(
        currentBalance: 0.0,
        monthlyIncome: 0.0,
        monthlyExpenses: 0.0,
      );
    }
  }

  @override
  Future<FinancialTransaction> addTransaction(FinancialTransaction transaction) async {
    try {
      final typeStr = transaction.type == TransactionType.income ? 'ingreso' : 'egreso';

      // Restricción RLS: Payload DEBE incluir 'id_iglesia'
      final payload = {
        'id_iglesia': transaction.churchId,
        'tipo': typeStr,
        'categoria': transaction.category,
        'monto': transaction.amount,
        'fecha': transaction.date.toIso8601String(),
        'donante_o_destinatario': transaction.donorOrRecipient,
        'descripcion': transaction.description,
        'comprobante_url': transaction.receiptImagePath,
        'tiene_comprobante': transaction.hasReceipt,
        'registrado_por': transaction.registeredBy,
      };

      final data = await _client
          .from('transacciones_financieras')
          .insert(payload)
          .select()
          .single();

      return _mapToTransaction(data);
    } catch (e) {
      debugPrint('[SupabaseTreasuryRepository] Error al registrar transacción: $e');
      rethrow;
    }
  }

  FinancialTransaction _mapToTransaction(Map<String, dynamic> data) {
    final rawType = (data['tipo'] ?? data['type'])?.toString().toLowerCase() ?? 'ingreso';
    final isIncome = rawType == 'ingreso' || rawType == 'income';
    final amountNum = (data['monto'] ?? data['amount'] as num?)?.toDouble() ?? 0.0;

    return FinancialTransaction(
      id: data['id']?.toString() ?? '',
      churchId: (data['id_iglesia'] ?? data['church_id'])?.toString() ?? '',
      type: isIncome ? TransactionType.income : TransactionType.expense,
      category: (data['categoria'] ?? data['category'])?.toString() ?? 'General',
      amount: amountNum,
      date: data['fecha'] != null
          ? DateTime.tryParse(data['fecha'].toString()) ?? DateTime.now()
          : (data['created_at'] != null
              ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      donorOrRecipient: (data['donante_o_destinatario'] ?? data['donor_or_recipient'])?.toString(),
      description: (data['descripcion'] ?? data['description'])?.toString() ?? '',
      receiptImagePath: (data['comprobante_url'] ?? data['receipt_image_path'])?.toString(),
      hasReceipt: (data['tiene_comprobante'] ?? data['has_receipt']) == true,
      registeredBy: (data['registrado_por'] ?? data['registered_by'])?.toString() ?? 'Tesorero',
    );
  }
}
