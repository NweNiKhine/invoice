import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime filterDate = DateTime.now();

  Future<void> _generatePdf(List<QueryDocumentSnapshot> docs, double totalAmt) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy').format(filterDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Purchase Report",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Date Filter: $dateStr"),
              pw.Divider(),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Invoice No', 'Qty', 'Amount'],
                data: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return [
                    data['date'],
                    data['invoiceNo'],
                    data['totalQty'].toString(),
                    "${data['totalAmount']} MMK"
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Grand Total: ${totalAmt.toStringAsFixed(2)} MMK",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedFilterDate =
    DateFormat('dd/MM/yyyy').format(filterDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Purchase Report",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: filterDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => filterDate = picked);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('purchases')
            .where('date', isEqualTo: formattedFilterDate)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;
          double totalAmt = 0;
          int totalQty = 0;

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            totalAmt += ((data['totalAmount'] ?? 0) as num).toDouble();
            totalQty += ((data['totalQty'] ?? 0) as num).toInt();
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.purple[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selected Date: $formattedFilterDate",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Total Invoices: ${docs.length}"),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Print PDF"),
                      onPressed: docs.isEmpty
                          ? null
                          : () => _generatePdf(docs, totalAmt),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _infoCard(
                        "Total Qty", totalQty.toString(), Colors.orange),
                    _infoCard(
                        "Total Amount",
                        "${totalAmt.toStringAsFixed(0)} MMK",
                        Colors.green),
                  ],
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? const Center(
                  child: Text(
                    "No data found for this date.",
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text('Invoice No')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Amount')),
                      ],
                      rows: docs.map((doc) {
                        var data =
                        doc.data() as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(
                              Text(data['invoiceNo'] ?? "-")),
                          DataCell(Text(
                              data['totalQty'].toString())),
                          DataCell(Text(
                              "${data['totalAmount']} MMK")),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
