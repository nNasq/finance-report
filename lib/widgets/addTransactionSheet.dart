import 'package:financialreport/models/trxModel.dart';
import 'package:financialreport/providers/trxProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  static Future show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const AddTransactionSheet(),
  );

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();

  TransactionType type = TransactionType.income;
  DateTime date = DateTime.now();
  bool loading = false;

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _typeButton('Pemasukan', TransactionType.income),
                const SizedBox(width: 8),
                _typeButton('Pengeluaran', TransactionType.expense),
              ],
            ),

            const SizedBox(height: 12),

            _field(
              controller: title,
              label: 'Nama Transaksi',
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 12),

            _field(
              controller: amount,
              label: 'Jumlah',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty || double.tryParse(v) == null
                  ? 'Jumlah tidak valid'
                  : null,
            ),

            const SizedBox(height: 12),

            _field(controller: note, label: 'Catatan'),

            const SizedBox(height: 12),

            ListTile(
              tileColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text('${date.day}/${date.month}/${date.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickDate,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _typeButton(String text, TransactionType value) {
    final selected = type == value;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.blue : Colors.grey.shade300,
        ),
        onPressed: () => setState(() => type = value),
        child: Text(
          text,
          style: TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Future pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (result != null) setState(() => date = result);
  }

  Future submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await context.read<TransactionProvider>().addTransaction(
      title: title.text,
      amount: double.parse(amount.text),
      type: type,
      date: date,
      note: note.text.isEmpty ? null : note.text,
    );

    if (mounted) Navigator.pop(context);
  }
}
