import '../../domain/entities/financial_transaction.dart';

abstract class TreasuryRepository {
  Future<List<FinancialTransaction>> getTransactions(String churchId);
  Future<FinancialSummary> getFinancialSummary(String churchId);
  Future<FinancialTransaction> addTransaction(FinancialTransaction transaction);
}

class MockTreasuryRepository implements TreasuryRepository {
  final List<FinancialTransaction> _transactions = [
    FinancialTransaction(
      id: 'tx-1',
      churchId: 'tenant-1',
      type: TransactionType.income,
      category: 'Diezmos y Ofrendas Dominicales',
      amount: 14500.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      donorOrRecipient: 'Culto General Domingo',
      description: 'Ofrenda y diezmo consolidado del servicio principal de las 11:00 AM.',
      registeredBy: 'Carlos Mendoza (Tesorero)',
    ),
    FinancialTransaction(
      id: 'tx-2',
      churchId: 'tenant-1',
      type: TransactionType.expense,
      category: 'Servicio de Electricidad (Disnorte/Dissur)',
      amount: 2840.50,
      date: DateTime.now().subtract(const Duration(days: 3)),
      donorOrRecipient: 'Disnorte - Distribuidora de Electricidad del Norte',
      description: 'Pago de recibo mensual de energía eléctrica del templo principal.',
      hasReceipt: true,
      registeredBy: 'Carlos Mendoza (Tesorero)',
    ),
    FinancialTransaction(
      id: 'tx-3',
      churchId: 'tenant-1',
      type: TransactionType.income,
      category: 'Fondo Pro-Templo',
      amount: 8000.00,
      date: DateTime.now().subtract(const Duration(days: 6)),
      donorOrRecipient: 'Donante Anónimo',
      description: 'Aporte especial para la adquisición de bocinas del sistema de sonido.',
      registeredBy: 'Pastor David Morales',
    ),
    FinancialTransaction(
      id: 'tx-4',
      churchId: 'tenant-1',
      type: TransactionType.expense,
      category: 'Ministerio Infantil / Escuela Dominical',
      amount: 1150.00,
      date: DateTime.now().subtract(const Duration(days: 8)),
      donorOrRecipient: 'Papelería La Escolar',
      description: 'Material didáctico, hojas, crayolas y refrigerios para 45 niños.',
      hasReceipt: true,
      registeredBy: 'Carlos Mendoza (Tesorero)',
    ),
    FinancialTransaction(
      id: 'tx-5',
      churchId: 'tenant-1',
      type: TransactionType.expense,
      category: 'Ayuda Social / Comedor Comunitario',
      amount: 3200.00,
      date: DateTime.now().subtract(const Duration(days: 12)),
      donorOrRecipient: 'Supermercado Central',
      description: 'Despensas y canastas básicas entregadas a 10 familias necesitadas.',
      hasReceipt: true,
      registeredBy: 'Carlos Mendoza (Tesorero)',
    ),
    FinancialTransaction(
      id: 'tx-6',
      churchId: 'tenant-1',
      type: TransactionType.income,
      category: 'Ofrenda Células Hogareñas',
      amount: 2450.00,
      date: DateTime.now().subtract(const Duration(days: 14)),
      donorOrRecipient: 'Células Zona Norte',
      description: 'Ofrendas recolectadas en las 5 reuniones celulares de la semana.',
      registeredBy: 'Carlos Mendoza (Tesorero)',
    ),
  ];

  @override
  Future<List<FinancialTransaction>> getTransactions(String churchId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_transactions);
  }

  @override
  Future<FinancialSummary> getFinancialSummary(String churchId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // Saldo inicial acumulado + ingresos del mes - egresos del mes
    const initialCash = 35000.0;
    final currentBalance = initialCash + totalIncome - totalExpense;

    return FinancialSummary(
      currentBalance: currentBalance,
      monthlyIncome: totalIncome,
      monthlyExpenses: totalExpense,
    );
  }

  @override
  Future<FinancialTransaction> addTransaction(FinancialTransaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.insert(0, transaction);
    return transaction;
  }
}
