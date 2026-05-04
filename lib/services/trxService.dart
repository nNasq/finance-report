import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:financialreport/models/trxModel.dart';

class TransactionService {
  final String baseUrl =
      "https://script.google.com/macros/s/AKfycbwvknjsUfzZSF6YaFfuz8ggkqjTdqCLeAo_YWdl2nQE8lAe5iKP687Cwh-CI5aD4uix/exec";

  Future<List<TransactionModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.body.trim().startsWith('<') || res.statusCode != 200) {
      print(res.body);
      throw Exception('Request gagal dengan status ${res.statusCode}.');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => TransactionModel.fromJson(e)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(TransactionModel trx) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(trx.toJson()),
    );
  }
}

