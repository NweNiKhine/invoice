import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../model/setup_model.dart';

class PurchaseEntryScreen extends StatefulWidget {
  final DocumentSnapshot? editData; // Purchase List မှ ပို့လိုက်သော Data

  const PurchaseEntryScreen({super.key, this.editData});

  @override
  _PurchaseEntryScreenState createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  DateTime selectedDate = DateTime.now();
  final invCtrl = TextEditingController();
  List<PurchaseItem> itemList = [];
  String? selectedStockCode;

  @override
  void initState() {
    super.initState();
    // Edit Mode: Invoice တစ်ခုလုံးကို ပြန်ပြင်ရန် Data ဖြည့်ခြင်း
    if (widget.editData != null) {
      final data = widget.editData!.data() as Map<String, dynamic>;
      invCtrl.text = data['invoiceNo'] ?? "";
      selectedDate = DateFormat('dd/MM/yyyy').parse(data['date']);

      if (data['items'] != null) {
        itemList = (data['items'] as List).map((i) => PurchaseItem(
          code: i['code'],
          description: i['description'] ?? "",
          qty: i['qty'] ?? 0,
          price: (i['price'] as num).toDouble(),
        )).toList();
      }
    }
  }

  // Dialog Function: ပစ္စည်းအသစ်ထည့်ရန်နှင့် ရှိပြီးသားကို ပြင်ရန် နှစ်မျိုးလုံးသုံးသည်
  void _showItemDialog({PurchaseItem? item, int? index}) async {
    // ပစ္စည်းရှိရင် Data ထည့်မယ်၊ မရှိရင် အလွတ်ထားမယ်
    final qtyCtrl = TextEditingController(text: item?.qty.toString() ?? "");
    final priceCtrl = TextEditingController(text: item?.price.toString() ?? "");
    final totalCtrl = TextEditingController(text: item?.amount.toStringAsFixed(2) ?? "0");

    String? tempCode = item?.code;
    String tempDesc = item?.description ?? "";

    // Stock Master မှ Code များကို ယူခြင်း
    var stocksSnap = await FirebaseFirestore.instance.collection('stocks').get();
    Map<String, String> stockMap = {
      for (var d in stocksSnap.docs) d['code']: d['description'],
    };
    List<String> stockCodes = stockMap.keys.toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? "Add Detail" : "Edit Item Detail"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: tempCode,
                  hint: const Text("Select Stock Code"),
                  items: stockCodes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() {
                    tempCode = val;
                    tempDesc = stockMap[val!]!;
                  }),
                ),
                SizedBox(height: 12,),
                Text("Desc: $tempDesc", style: const TextStyle(fontSize: 14, color: Colors.black)),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: "QTY"),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => totalCtrl.text =
                      ((double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0)).toStringAsFixed(2),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => totalCtrl.text =
                      ((double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0)).toStringAsFixed(2),
                ),
                TextField(controller: totalCtrl, decoration: const InputDecoration(labelText: "Total"), readOnly: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (tempCode == null || qtyCtrl.text.isEmpty) return;

                setState(() {
                  PurchaseItem newItem = PurchaseItem(
                    code: tempCode!,
                    description: tempDesc,
                    qty: int.parse(qtyCtrl.text),
                    price: double.parse(priceCtrl.text),
                  );

                  if (index == null) {
                    itemList.add(newItem); // Add new item
                  } else {
                    itemList[index] = newItem; // Update existing item
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index == null ? "Add" : "Update"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToFirebase() async {
    if (invCtrl.text.isEmpty || itemList.isEmpty) return;

    double totalAmt = itemList.fold(0, (sum, i) => sum + i.amount);
    int totalQty = itemList.fold(0, (sum, i) => sum + i.qty);

    final data = {
      'invoiceNo': invCtrl.text,
      'date': DateFormat('dd/MM/yyyy').format(selectedDate),
      'totalQty': totalQty,
      'totalAmount': totalAmt,
      'items': itemList.map((e) => {
        'code': e.code,
        'description': e.description,
        'qty': e.qty,
        'price': e.price,
        'amount': e.amount
      }).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (widget.editData != null) {
      await FirebaseFirestore.instance.collection('purchases').doc(widget.editData!.id).update(data);
    } else {
      await FirebaseFirestore.instance.collection('purchases').add(data);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editData != null ? "Edit Purchase" : "Purchase Entry"),
        backgroundColor: Colors.purple,
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveToFirebase)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  Text("Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}", style: const TextStyle(fontSize: 16)),
                  IconButton(icon: const Icon(Icons.calendar_today, color: Colors.purple), onPressed: () async {
                    DateTime? p = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (p != null) setState(() => selectedDate = p);
                  }),
                ]),
                TextField(controller: invCtrl, decoration: const InputDecoration(labelText: "Invoice No")),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Detail"),
                  onPressed: () => _showItemDialog(), // ပစ္စည်းအသစ်ထည့်ရန် ခေါ်ခြင်း
                ),
              ],
            ),
          ),
          // Table Header
          Container(
            color: Colors.purple[50],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(children: [
              SizedBox(width: 40, child: Text("Sr", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text("Qty", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Amount", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 40), // Delete button space
            ]),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                final item = itemList[index];
                return InkWell(
                  onTap: () => _showItemDialog(item: item, index: index), // Row ကိုနှိပ်ရင် Dialog ဖြင့် ပြန်ပြင်ရန်
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))),
                    child: Row(children: [
                      SizedBox(width: 40, child: Text("${index + 1}", textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(item.code)),
                      Expanded(flex: 3, child: Text(item.description, overflow: TextOverflow.ellipsis)),
                      Expanded(flex: 1, child: Text("${item.qty}", textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(item.amount.toStringAsFixed(0), textAlign: TextAlign.right, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                        onPressed: () => setState(() => itemList.removeAt(index)),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          // Total Amount Footer
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Total Amount: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${itemList.fold(0.0, (sum, item) => sum + item.amount).toStringAsFixed(2)} MMK",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}