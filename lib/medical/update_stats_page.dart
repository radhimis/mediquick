import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateStatsPage extends StatefulWidget {
  const UpdateStatsPage({super.key});

  @override
  _UpdateStatsPageState createState() => _UpdateStatsPageState();
}

class _UpdateStatsPageState extends State<UpdateStatsPage> {
  final _formKey = GlobalKey<FormState>();
  final _totalOrdersController = TextEditingController();
  final _totalRevenueController = TextEditingController();
  final _avgDeliveryTimeController = TextEditingController();
  final _onTimeRateController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _currentStats = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
  }

  @override
  void dispose() {
    _totalOrdersController.dispose();
    _totalRevenueController.dispose();
    _avgDeliveryTimeController.dispose();
    _onTimeRateController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentStats() async {
    try {
      final client = Supabase.instance.client;
      final stats = await client.from('dashboard_stats').select('*');

      final statsMap = <String, dynamic>{};
      for (final stat in stats) {
        statsMap[stat['metric_name']] = stat['value'];
      }

      setState(() {
        _currentStats = statsMap;
        _totalOrdersController.text = statsMap['total_orders']?.toString() ?? '0';
        _totalRevenueController.text = statsMap['total_revenue']?.toString() ?? '0';
        _avgDeliveryTimeController.text = statsMap['avg_delivery_time']?.toString() ?? '0';
        _onTimeRateController.text = (statsMap['on_time_delivery_rate'] != null
            ? (statsMap['on_time_delivery_rate'] * 100).toStringAsFixed(1)
            : '0');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading stats: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStats() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final statsToUpdate = [
        {
          'metric_name': 'total_orders',
          'value': int.parse(_totalOrdersController.text),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'metric_name': 'total_revenue',
          'value': double.parse(_totalRevenueController.text),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'metric_name': 'avg_delivery_time',
          'value': double.parse(_avgDeliveryTimeController.text),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'metric_name': 'on_time_delivery_rate',
          'value': double.parse(_onTimeRateController.text) / 100,
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      for (final stat in statsToUpdate) {
        await client
            .from('dashboard_stats')
            .upsert(stat, onConflict: 'metric_name');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dashboard stats updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Dashboard Stats'),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E90FF),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildCurrentStat('Total Orders', _currentStats['total_orders']?.toString() ?? '0'),
                        _buildCurrentStat('Total Revenue', '₹${_currentStats['total_revenue']?.toString() ?? '0'}'),
                        _buildCurrentStat('Avg Delivery Time', '${_currentStats['avg_delivery_time']?.toString() ?? '0'} mins'),
                        _buildCurrentStat('On-time Rate', '${(_currentStats['on_time_delivery_rate'] != null ? (_currentStats['on_time_delivery_rate'] * 100).toStringAsFixed(1) : '0')}%'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Update Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E90FF),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _totalOrdersController,
                  decoration: InputDecoration(
                    labelText: 'Total Orders',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total orders';
                    }
                    final orders = int.tryParse(value);
                    if (orders == null || orders < 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _totalRevenueController,
                  decoration: InputDecoration(
                    labelText: 'Total Revenue (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total revenue';
                    }
                    final revenue = double.tryParse(value);
                    if (revenue == null || revenue < 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _avgDeliveryTimeController,
                  decoration: InputDecoration(
                    labelText: 'Average Delivery Time (minutes)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter average delivery time';
                    }
                    final time = double.tryParse(value);
                    if (time == null || time < 0) {
                      return 'Please enter a valid time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _onTimeRateController,
                  decoration: InputDecoration(
                    labelText: 'On-time Delivery Rate (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter on-time rate';
                    }
                    final rate = double.tryParse(value);
                    if (rate == null || rate < 0 || rate > 100) {
                      return 'Please enter a valid percentage (0-100)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateStats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E90FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Update Statistics',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStat(String label, String value) {
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
