import 'package:financialreport/models/summaryModel.dart';
import 'package:financialreport/models/trxModel.dart';
import 'package:financialreport/services/trxService.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider extends ChangeNotifier {
  final _service = TransactionService();
  final _uuid = const Uuid();

  List<TransactionModel> transactions = [];
  bool isLoading = false;
  String? error;

  FinancialSummary get summary {
    final income = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    return FinancialSummary(
      totalBalance: income - expense,
      totalIncome: income,
      totalExpense: expense,
    );
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      transactions = await _service.getAll();
      print("Loaded ${transactions.length} transactions");
    } catch (e) {
      error = e.toString();
      print("Error loading transactions: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    String? note,
  }) async {
    final trx = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      date: date,
      note: note,
    );

    transactions.insert(0, trx);
    notifyListeners();

    try {
      await _service.add(trx);
    } catch (e) {
      transactions.removeWhere((t) => t.id == trx.id);
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final backup = List<TransactionModel>.from(transactions);

    transactions.removeWhere((t) => t.id == id);
    notifyListeners();

    try {
      await _service.delete(id);
    } catch (e) {
      transactions = backup;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    String? note,
  }) async {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final backup = transactions[index];

    final updated = TransactionModel(
      id: id,
      title: title,
      amount: amount,
      type: type,
      date: date,
      note: note,
    );

    transactions[index] = updated;
    // Urutkan ulang berdasarkan tanggal
    transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    try {
      await _service.update(updated);
    } catch (e) {
      // Rollback jika gagal
      transactions[index] = backup;
      transactions.sort((a, b) => b.date.compareTo(a.date));
      error = e.toString();
      notifyListeners();
    }
  }
}
