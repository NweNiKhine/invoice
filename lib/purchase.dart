import 'package:flutter/material.dart';
import 'package:untitled1/addnewitem.dart';

class Purchase extends StatelessWidget {
  const Purchase({super.key});

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
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                _HeaderCell('Date', flex: 2),
                _HeaderCell('Invoice No', flex: 3),
                _HeaderCell('QTY', flex: 2),
                _HeaderCell('Amount', flex: 3),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                _TableRow(
                  date: '30/01/2019',
                  invoice: 'Inv-0001',
                  qty: '15',
                  amount: '12,500',
                ),
                _TableRow(
                  date: '30/01/2019',
                  invoice: 'Inv-0002',
                  qty: '10',
                  amount: '5,000',
                ),
                _TableRow(
                  date: '30/01/2019',
                  invoice: 'Inv-0003',
                  qty: '10',
                  amount: '10,000',
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            color: Colors.grey.shade300,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PurchaseNewPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.add, size: 30),
                            SizedBox(width: 4),
                            Text('New'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.edit, size: 30),
                      const SizedBox(width: 4),
                      const Text('Edit'),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    '35',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      '27,500',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

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

class _TableRow extends StatelessWidget {
  final String date;
  final String invoice;
  final String qty;
  final String amount;

  const _TableRow({
    required this.date,
    required this.invoice,
    required this.qty,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _cell(date, 2),
          _cell(invoice, 3),
          _cell(qty, 2),
          _cell(amount, 3, rightAlign: true),
        ],
      ),
    );
  }

  Widget _cell(String text, int flex, {bool rightAlign = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign:
        rightAlign ? TextAlign.right : TextAlign.center,
      ),
    );
  }
}
