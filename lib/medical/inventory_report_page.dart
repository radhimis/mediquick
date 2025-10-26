import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryReportPage extends StatefulWidget {
  @override
  _InventoryReportPageState createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  List<Map<String, dynamic>> medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('medicines')
          .select('*')
          .order('stock_quantity', ascending: true);

      setState(() {
        medicines = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading inventory data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Report'),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medicine Stock Levels',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: medicines.isEmpty
                        ? Center(child: Text('No medicines in inventory'))
                        : ListView.builder(
                            itemCount: medicines.length,
                            itemBuilder: (context, index) {
                              final medicine = medicines[index];
                              final stock = medicine['stock_quantity'] ?? 0;
                              final isLowStock = stock < 10;
                              final isExpiringSoon = medicine['expiry_date'] != null &&
                                  DateTime.parse(medicine['expiry_date']).isBefore(DateTime.now().add(Duration(days: 30)));

                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                color: isLowStock ? Colors.red[50] : (isExpiringSoon ? Colors.orange[50] : null),
                                child: ListTile(
                                  title: Text(medicine['name'] ?? 'Unknown'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Stock: $stock units'),
                                      Text('Category: ${medicine['description'] ?? 'N/A'}'),
                                      if (medicine['expiry_date'] != null)
                                        Text('Expiry: ${medicine['expiry_date']}'),
                                    ],
                                  ),
                                  trailing: Icon(
                                    isLowStock ? Icons.warning : (isExpiringSoon ? Icons.schedule : Icons.check_circle),
                                    color: isLowStock ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.green),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
