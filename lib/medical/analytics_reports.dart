import 'package:flutter/material.dart';
import 'update_stats_page.dart';
import 'sales_report_page.dart';
import 'inventory_report_page.dart';
import 'customer_insights_page.dart';
import 'performance_metrics_page.dart';

class AnalyticsReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics & Reports'),
        backgroundColor: Color(0xFF1E90FF),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateStatsPage()),
              );
              if (result == true) {
                // Stats updated successfully
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dashboard statistics updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAnalyticsCard(
                    context,
                    'Sales Report',
                    Icons.trending_up,
                    Colors.green,
                    'View detailed sales analytics',
                  ),
                  _buildAnalyticsCard(
                    context,
                    'Inventory Report',
                    Icons.inventory,
                    Colors.blue,
                    'Check stock levels and trends',
                  ),
                  _buildAnalyticsCard(
                    context,
                    'Customer Insights',
                    Icons.people,
                    Colors.purple,
                    'Analyze customer behavior',
                  ),
                  _buildAnalyticsCard(
                    context,
                    'Performance Metrics',
                    Icons.bar_chart,
                    Colors.orange,
                    'Delivery and service metrics',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, String title, IconData icon, Color color, String description) {
    return GestureDetector(
      onTap: () {
        Widget page;
        switch (title) {
          case 'Sales Report':
            page = SalesReportPage();
            break;
          case 'Inventory Report':
            page = InventoryReportPage();
            break;
          case 'Customer Insights':
            page = CustomerInsightsPage();
            break;
          case 'Performance Metrics':
            page = PerformanceMetricsPage();
            break;
          default:
            return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
