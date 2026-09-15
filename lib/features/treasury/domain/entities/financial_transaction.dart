enum TransactionType {
  income('Ingreso', '+'),
  expense('Egreso', '-');

  final String label;
  final String sign;

  const TransactionType(this.label, this.sign);
}

class FinancialTransaction {
  final String id;
  final String churchId;
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String? donorOrRecipient;
  final String description;
  final String? receiptImagePath;
  final bool hasReceipt;
  final String registeredBy;

  const FinancialTransaction({
    required this.id,
    required this.churchId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.donorOrRecipient,
    required this.description,
    this.receiptImagePath,
    this.hasReceipt = false,
    required this.registeredBy,
  });

  FinancialTransaction copyWith({
    String? id,
    String? churchId,
    TransactionType? type,
    String? category,
    double? amount,
    DateTime? date,
    String? donorOrRecipient,
    String? description,
    String? receiptImagePath,
    bool? hasReceipt,
    String? registeredBy,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      donorOrRecipient: donorOrRecipient ?? this.donorOrRecipient,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      registeredBy: registeredBy ?? this.registeredBy,
    );
  }
}

class FinancialSummary {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  const FinancialSummary({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });
}
