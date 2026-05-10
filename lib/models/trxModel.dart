enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  bool get isIncome => type == TransactionType.income;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type.name,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      
      // Menggunakan orElse agar tidak terjadi Bad state: No element
      type: TransactionType.values.firstWhere(
        (e) => e.name.toLowerCase() == json['type']?.toString().toLowerCase(),
        orElse: () => TransactionType.expense, 
      ),
      
      // Menggunakan tryParse agar tidak error jika format tanggal salah atau kosong
      date: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),
      
      note: json['note']?.toString(),
    );
  }
}