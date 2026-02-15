import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'purchase_entry_screen.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  _PurchaseListScreenState createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  DocumentSnapshot? selectedDoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase List", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('purchases')
                  .orderBy('timestamp', descending: true) // အသစ်ဆုံးကို အပေါ်ကပြရန်
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: true, // Checkbox ပြရန်
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Invoice No')),
                        DataColumn(label: Text('QTY')),
                        DataColumn(label: Text('Amount')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(
                          // Row ကို Select လုပ်ထားခြင်း ရှိ/မရှိ စစ်ဆေးခြင်း
                          selected: selectedDoc?.id == doc.id,
                          onSelectChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                selectedDoc = doc;
                              } else {
                                selectedDoc = null;
                              }
                            });
                          },
                          cells: [
                            DataCell(Text(data['date'] ?? '-')),
                            DataCell(Text(data['invoiceNo'] ?? '-')),
                            DataCell(Text((data['totalQty'] ?? 0).toString())),
                            DataCell(Text((data['totalAmount'] ?? 0).toStringAsFixed(2))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          // အောက်ခြေ Action Bar
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                // NEW Button
                _bottomAction(Icons.add, "New", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PurchaseEntryScreen(),
                    ),
                  );
                }),
                const SizedBox(width: 40),
                // EDIT Button
                _bottomAction(
                  Icons.edit_note,
                  "Edit",
                  selectedDoc == null
                      ? null // ရွေးမထားရင် Edit နှိပ်လို့မရအောင်လုပ်ခြင်း
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseEntryScreen(editData: selectedDoc),
                      ),
                    );
                  },
                  color: selectedDoc == null ? Colors.grey : Colors.blue,
                ),
                const SizedBox(width: 40),
                // DELETE Button (Optional but useful)
                _bottomAction(
                  Icons.delete_outline,
                  "Delete",
                  selectedDoc == null
                      ? null
                      : () {
                    _confirmDelete(context);
                  },
                  color: selectedDoc == null ? Colors.grey : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Delete လုပ်ရန် Confirm ပေးခြင်း
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete this invoice?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                selectedDoc!.reference.delete();
                setState(() => selectedDoc = null);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, VoidCallback? onTap, {Color color = Colors.black}) {
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0, // Disable ဖြစ်နေရင် မှိန်ပြခြင်း
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}