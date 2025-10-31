import 'package:flutter/material.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;
  final String estimatedDelivery;
  final int currentStep; // 0=Placed, 1=Packed, 2=Out for Delivery, 3=Delivered

  const TrackingPage({
    super.key,
    required this.orderId,
    required this.estimatedDelivery,
    required this.currentStep,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final List<Map<String, String>> _steps = [
    {"title": "Order Placed", "subtitle": "14 Sep 2025, 10:30 AM"},
    {"title": "Packed", "subtitle": "14 Sep 2025, 11:15 AM"},
    {"title": "Out for Delivery", "subtitle": "Your order is on its way."},
    {"title": "Delivered", "subtitle": "Your order has been delivered."},
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Order Info Card ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ESTIMATED DELIVERY",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.estimatedDelivery,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "ORDER ID",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.orderId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Tracking Steps ---
            Column(
              children: List.generate(_steps.length, (index) {
                final isCompleted = index < widget.currentStep;
                final isActive = index == widget.currentStep;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCompleted || isActive
                                ? primary
                                : Colors.white,
                            border: Border.all(
                              color: isCompleted || isActive
                                  ? primary
                                  : Colors.grey,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : (isActive
                                      ? Icons.radio_button_checked
                                      : Icons.circle_outlined),
                            size: 16,
                            color: isCompleted || isActive
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                        if (index != _steps.length - 1)
                          Container(
                            width: 2,
                            height: 50,
                            color: isCompleted ? primary : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _steps[index]["title"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isCompleted || isActive
                                    ? primary
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _steps[index]["subtitle"]!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 20),

            // --- Help Button ---
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Support coming soon!")),
                );
              },
              icon: const Icon(Icons.help_outline, color: Colors.teal),
              label: const Text(
                "Need Help?",
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
