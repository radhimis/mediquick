import 'package:flutter/material.dart';
import 'user_routes.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: FAQPage()));
}

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "What is MediQuick?",
      "answer":
          "MediQuick is a healthcare platform that connects patients with nearby pharmacies for quick medicine delivery.",
    },
    {
      "question": "How does MediQuick work?",
      "answer":
          "Upload your prescription or search for medicines, select a nearby pharmacy, and place your order. Delivery is managed by the pharmacy.",
    },
    {
      "question": "Do I need a prescription to order medicines?",
      "answer":
          "Yes, prescription medicines require a valid doctor's prescription. OTC and wellness products don’t need one.",
    },
    {
      "question": "How long does delivery take?",
      "answer":
          "MediQuick aims to deliver medicines within a few hours, depending on your location and pharmacy availability.",
    },
    {
      "question": "Is my medical data safe?",
      "answer":
          "Yes, all your personal and medical data is encrypted and securely shared only with verified pharmacies.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true, // ✅ center align title
        title: const Text(
          "FAQs",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), // ✅ extra top space
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ExpansionTile(
                iconColor: Colors.blue.shade600,
                collapsedIconColor: Colors.blue.shade600,
                title: Text(
                  faqs[index]["question"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      faqs[index]["answer"]!,
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
