import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled1/ui/purchase_list_screen.dart';
import 'package:untitled1/ui/report_screen.dart';
import 'package:untitled1/ui/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GalaxyApp());
}

class GalaxyApp extends StatelessWidget {
  const GalaxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Title", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Setup"),
              onTap: () {
                Navigator.pop(context); // Drawer ကို အရင်ပိတ်မယ်
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetupScreen(),
                  ), // SetupScreen သို့ သွားမယ်
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.money),

              title: Text("Purchase"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PurchaseListScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.shop),

              title: Text("Sales"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.report),

              title: Text("Report"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen()),
              ),            ),
          ],
        ),
      ),
      body: Center(child: Text("Welcome to Galaxy Software")),
    );
  }
}
