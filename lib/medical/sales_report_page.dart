import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  List<Map<String, dynamic>> salesData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    try {
      final client = Supabase.instance.client;

      // Get orders from last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      final orders = await client
          .from('orders')
          .select('*')
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false);

      // Group by date
      final Map<String, Map<String, dynamic>> dailySales = {};

      for (final order in orders) {
        final date = DateTime.parse(order['created_at']).toIso8601String().split('T')[0];
        if (!dailySales.containsKey(date)) {
          dailySales[date] = {
            'date': date,
            'total_orders': 0,
            'total_revenue': 0.0,
            'orders': [],
          };
        }
        dailySales[date]!['total_orders'] += 1;
        dailySales[date]!['total_revenue'] += order['total_amount'];
        dailySales[date]!['orders'].add(order);
      }

      setState(() {
        salesData = dailySales.values.toList()
          ..sort((a, b) => b['date'].compareTo(a['date']));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading sales data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Report'),
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
                    'Daily Sales (Last 30 Days)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: salesData.isEmpty
                        ? Center(child: Text('No sales data available'))
                        : ListView.builder(
                            itemCount: salesData.length,
                            itemBuilder: (context, index) {
                              final data = salesData[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text('Date: ${data['date']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Orders: ${data['total_orders']}'),
                                      Text('Revenue: ₹${data['total_revenue'].toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () => _showOrderDetails(data['orders']),
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

  void _showOrderDetails(List<dynamic> orders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order #${order['id']}'),
                subtitle: Text('Customer: ${order['customer_name']} - ₹${order['total_amount']}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
