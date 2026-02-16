import 'package:flutter/material.dart';

class PurchaseNewPage extends StatelessWidget {
  const PurchaseNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Purchase',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white),
                Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Date.')),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '30/01/2019',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Invoice No.')),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Inv-00001',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () {},
                    child: const Text('Add Detail'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                _Header('Sr', 1),
                _Header('Stock Code', 2),
                _Header('Description', 4),
                _Header('Qty', 1),
                _Header('Price', 2),
                _Header('Amount', 2),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                _RowData('1', '1001', 'Book', '10', '1000', '10000'),
                _RowData('2', '1002', 'Pen', '5', '500', '2500'),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade300,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Total QTY\n15',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total Amount\n12,500',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final int flex;

  const _Header(this.text, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RowData extends StatelessWidget {
  final String sr, code, desc, qty, price, amount;

  const _RowData(
      this.sr,
      this.code,
      this.desc,
      this.qty,
      this.price,
      this.amount,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          _cell(sr, 1),
          _cell(code, 2),
          _cell(desc, 4),
          _cell(qty, 1),
          _cell(price, 2),
          _cell(amount, 2, right: true),
        ],
      ),
    );
  }

  Widget _cell(String text, int flex, {bool right = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: right ? TextAlign.right : TextAlign.center,
      ),
    );
  }
}
