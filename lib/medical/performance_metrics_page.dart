import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerformanceMetricsPage extends StatefulWidget {
  @override
  _PerformanceMetricsPageState createState() => _PerformanceMetricsPageState();
}

class _PerformanceMetricsPageState extends State<PerformanceMetricsPage> {
  Map<String, dynamic> metrics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    try {
      final client = Supabase.instance.client;
      final deliveries = await client
          .from('deliveries')
          .select('*')
          .order('created_at', ascending: false);

      if (deliveries.isEmpty) {
        setState(() {
          metrics = {
            'total_deliveries': 0,
            'on_time_deliveries': 0,
            'on_time_rate': 0.0,
            'avg_delivery_time': 0.0,
          };
          _isLoading = false;
        });
        return;
      }

      final totalDeliveries = deliveries.length;
      final onTimeDeliveries = deliveries.where((d) => d['on_time'] == true).length;
      final onTimeRate = onTimeDeliveries / totalDeliveries;

      final totalTime = deliveries.fold<int>(0, (sum, d) => sum + (d['delivery_time_minutes'] as int));
      final avgTime = totalTime / totalDeliveries;

      setState(() {
        metrics = {
          'total_deliveries': totalDeliveries,
          'on_time_deliveries': onTimeDeliveries,
          'on_time_rate': onTimeRate,
          'avg_delivery_time': avgTime,
          'deliveries': deliveries,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading performance data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Metrics'),
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
                    'Delivery Performance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildMetricRow('Total Deliveries', '${metrics['total_deliveries']}'),
                          _buildMetricRow('On-time Deliveries', '${metrics['on_time_deliveries']}'),
                          _buildMetricRow('On-time Rate', '${(metrics['on_time_rate'] * 100).toStringAsFixed(1)}%'),
                          _buildMetricRow('Avg Delivery Time', '${metrics['avg_delivery_time'].toStringAsFixed(1)} mins'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Recent Deliveries',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: (metrics['deliveries'] as List?)?.isEmpty ?? true
                        ? Center(child: Text('No delivery data available'))
                        : ListView.builder(
                            itemCount: (metrics['deliveries'] as List).length,
                            itemBuilder: (context, index) {
                              final delivery = (metrics['deliveries'] as List)[index];
                              final isOnTime = delivery['on_time'] == true;
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text('Order #${delivery['order_id']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Delivery Time: ${delivery['delivery_time_minutes']} mins'),
                                      Text('On Time: ${isOnTime ? 'Yes' : 'No'}'),
                                      Text('Date: ${DateTime.parse(delivery['delivery_date']).toLocal().toString().split(' ')[0]}'),
                                    ],
                                  ),
                                  trailing: Icon(
                                    isOnTime ? Icons.check_circle : Icons.cancel,
                                    color: isOnTime ? Colors.green : Colors.red,
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

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E90FF))),
        ],
      ),
    );
  }
}
