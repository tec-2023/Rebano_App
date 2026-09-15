import 'package:flutter/material.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../data/repositories/mock_treasury_repository.dart';
import '../services/export_service.dart';

enum TreasuryFilter { all, income, expense }

class TreasuryProvider extends ChangeNotifier {
  final TreasuryRepository _repository;

  List<FinancialTransaction> _transactions = [];
  FinancialSummary? _summary;
  TreasuryFilter _currentFilter = TreasuryFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  TreasuryProvider({TreasuryRepository? repository})
      : _repository = repository ?? MockTreasuryRepository() {
    loadTreasuryData('tenant-1');
  }

  List<FinancialTransaction> get transactions => _transactions;
  FinancialSummary? get summary => _summary;
  TreasuryFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<FinancialTransaction> get filteredTransactions {
    switch (_currentFilter) {
      case TreasuryFilter.income:
        return _transactions.where((t) => t.type == TransactionType.income).toList();
      case TreasuryFilter.expense:
        return _transactions.where((t) => t.type == TransactionType.expense).toList();
      case TreasuryFilter.all:
        return _transactions;
    }
  }

  void setFilter(TreasuryFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadTreasuryData(String churchId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getTransactions(churchId),
        _repository.getFinancialSummary(churchId),
      ]);
      _transactions = results[0] as List<FinancialTransaction>;
      _summary = results[1] as FinancialSummary;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar tesorería: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerIncome({
    required String churchId,
    required String category,
    required double amount,
    required DateTime date,
    String? donor,
    required String description,
    required String registeredBy,
  }) async {
    final transaction = FinancialTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      churchId: churchId,
      type: TransactionType.income,
      category: category,
      amount: amount,
      date: date,
      donorOrRecipient: donor,
      description: description,
      registeredBy: registeredBy,
    );

    try {
      final created = await _repository.addTransaction(transaction);
      _transactions.insert(0, created);
      // Actualizar resumen local
      if (_summary != null) {
        _summary = FinancialSummary(
          currentBalance: _summary!.currentBalance + amount,
          monthlyIncome: _summary!.monthlyIncome + amount,
          monthlyExpenses: _summary!.monthlyExpenses,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar ingreso: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerExpense({
    required String churchId,
    required String category,
    required double amount,
    required DateTime date,
    String? recipient,
    required String description,
    String? receiptImagePath,
    required String registeredBy,
  }) async {
    final transaction = FinancialTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      churchId: churchId,
      type: TransactionType.expense,
      category: category,
      amount: amount,
      date: date,
      donorOrRecipient: recipient,
      description: description,
      receiptImagePath: receiptImagePath,
      hasReceipt: receiptImagePath != null,
      registeredBy: registeredBy,
    );

    try {
      final created = await _repository.addTransaction(transaction);
      _transactions.insert(0, created);
      // Actualizar resumen local
      if (_summary != null) {
        _summary = FinancialSummary(
          currentBalance: _summary!.currentBalance - amount,
          monthlyIncome: _summary!.monthlyIncome,
          monthlyExpenses: _summary!.monthlyExpenses + amount,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar egreso: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> exportToExcel(String churchName) async {
    return await ExportService.exportTransactionsToCsv(
      transactions: _transactions,
      churchName: churchName,
    );
  }
}
