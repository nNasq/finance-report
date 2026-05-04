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

  
}
