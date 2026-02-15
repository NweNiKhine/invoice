import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final codeCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final salePriceCtrl=TextEditingController();
  bool isEditing = false;
  String? currentDocId;
  String? originalCode; // Edit လုပ်ချိန်မှာ Code ကို မပြောင်းဘဲ သိမ်းရင် Unique စစ်တာ ကျော်ဖို့

  void _handleSubmit() async {
    String code = codeCtrl.text.trim();
    String desc = descCtrl.text.trim();
    String salePrice=salePriceCtrl.text.trim();

    if (code.isEmpty || desc.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    if (!(isEditing && code == originalCode)) {
      var existingDocs = await FirebaseFirestore.instance
          .collection('stocks')
          .where('code', isEqualTo: code)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        _showSnackBar(
          "Stock Code '$code' already exists! Please use a unique code.",
        );
        return;
      }
    }

    if (isEditing && currentDocId != null) {
      await FirebaseFirestore.instance
          .collection('stocks')
          .doc(currentDocId)
          .update({'code': code, 'description': desc,'saleprice':salePrice});
      _showSnackBar("Stock updated successfully");
    } else {
      await FirebaseFirestore.instance.collection('stocks').add({
        'code': code,
        'description': desc,
        'saleprice':salePrice ?? "-",
        'createdAt': FieldValue.serverTimestamp(),
      });
      _showSnackBar("New stock added");
    }

    _clearForm();
  }

  void _clearForm() {
    setState(() {
      isEditing = false;
      currentDocId = null;
      originalCode = null;
      codeCtrl.clear();
      descCtrl.clear();
      salePriceCtrl.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _prepareEdit(DocumentSnapshot doc) {
    setState(() {
      isEditing = true;
      currentDocId = doc.id;
      originalCode = doc['code'];
      codeCtrl.text = doc['code'];
      descCtrl.text = doc['description'];
      salePriceCtrl.text=doc['saleprice'];
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Setup", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      isEditing ? "Edit Stock" : "Create New Stock",
                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(
                        labelText: "Stock Code",
                      ),
                    ),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                    TextField(
                      controller: salePriceCtrl,
                      decoration: const InputDecoration(
                        labelText: "Sale Price",
                      ),
                    ),


                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (isEditing)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearForm,
                              child: const Text("Cancel"),
                            ),
                          ),
                        if (isEditing) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditing
                                  ? Colors.orange
                                  : Colors.purple,
                            ),
                            onPressed: _handleSubmit,
                            child: Text(
                              isEditing ? "Update" : "Save",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Table Header
          Container(
            color: Colors.purple[100],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Stock Code",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Sale Price",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Expanded(
                //   flex: 3,
                //   child: Text(
                //     "Purchase Price",
                //     style: TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),
                SizedBox(
                  width: 80,
                  child: Text(
                    "Action",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // StreamBuilder with Alphabetical Ordering
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stocks')
                  .orderBy('code')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              data['code'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: Text(data['description'])),
                          Expanded(flex: 3, child: Text(data['saleprice'])),


                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () => _prepareEdit(data),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => data.reference.delete(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
