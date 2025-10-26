import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_client.dart';

class OCRResultsPage extends StatefulWidget {
  final String extractedText;
  final List<Map<String, dynamic>> medicines;
  final File imageFile;
  final Map<String, dynamic>? verifiedPrescription;

  const OCRResultsPage({
    super.key,
    required this.extractedText,
    required this.medicines,
    required this.imageFile,
    this.verifiedPrescription,
  });

  @override
  _OCRResultsPageState createState() => _OCRResultsPageState();
}

class _OCRResultsPageState extends State<OCRResultsPage> {
  List<Map<String, dynamic>> _matchedMedicines = [];
  List<Map<String, dynamic>> _selectedMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _matchMedicinesWithDatabase();
  }

  Future<void> _matchMedicinesWithDatabase() async {
    try {
      // Get all medicines from database
      final response = await SupabaseClientManager.client
          .from('medicines')
          .select('id, name, price, stock_quantity, unit, description');

      final allMedicines = List<Map<String, dynamic>>.from(response);

      // Match extracted medicines with database medicines
      for (var extractedMedicine in widget.medicines) {
        String extractedName = extractedMedicine['name']?.toString().toLowerCase() ?? '';

        // Find best match using fuzzy matching
        Map<String, dynamic>? bestMatch;
        double bestScore = 0.0;

        for (var dbMedicine in allMedicines) {
          String dbName = dbMedicine['name']?.toString().toLowerCase() ?? '';
          double score = _calculateSimilarity(extractedName, dbName);

          if (score > bestScore && score > 0.6) { // 60% similarity threshold
            bestMatch = Map<String, dynamic>.from(dbMedicine);
            bestMatch['extracted_info'] = extractedMedicine;
            bestMatch['confidence_score'] = score;
            bestScore = score;
          }
        }

        if (bestMatch != null) {
          _matchedMedicines.add(bestMatch);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error matching medicines: $e')),
      );
    }
  }

  double _calculateSimilarity(String str1, String str2) {
    // Simple Levenshtein distance based similarity
    if (str1 == str2) return 1.0;

    int len1 = str1.length;
    int len2 = str2.length;

    if (len1 == 0 || len2 == 0) return 0.0;

    List<List<int>> matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) matrix[i][0] = i;
    for (int j = 0; j <= len2; j++) matrix[0][j] = j;

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        int cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    int maxLen = len1 > len2 ? len1 : len2;
    return 1.0 - (matrix[len1][len2] / maxLen);
  }

  void _toggleMedicineSelection(Map<String, dynamic> medicine) {
    setState(() {
      if (_selectedMedicines.contains(medicine)) {
        _selectedMedicines.remove(medicine);
      } else {
        _selectedMedicines.add(medicine);
      }
    });
  }

  void _addToCart() {
    if (_selectedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one medicine')),
      );
      return;
    }

    // Here you would typically add to cart/order
    // For now, just show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_selectedMedicines.length} medicine(s) to cart'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to home or cart page
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _findGenericAlternatives() {
    if (_selectedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one medicine')),
      );
      return;
    }

    // Extract medicine names from selected medicines
    final medicineNames = _selectedMedicines
        .map((medicine) => medicine['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    // Navigate to generic alternatives page
    Navigator.pushNamed(
      context,
      '/generic-alternatives',
      arguments: {'medicines': medicineNames},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Medicines'),
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        actions: [
          if (_selectedMedicines.isNotEmpty)
            TextButton(
              onPressed: _addToCart,
              child: Text(
                'Add to Cart (${_selectedMedicines.length})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Matching medicines with database...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // Extracted text preview
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.verifiedPrescription != null ? 'Verified Prescription:' : 'Extracted Text:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.verifiedPrescription != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.extractedText,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        if (widget.verifiedPrescription != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prescription Details:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('ID: ${widget.verifiedPrescription!['id']}', style: const TextStyle(fontSize: 12)),
                                Text('Doctor: ${widget.verifiedPrescription!['doctor_name']}', style: const TextStyle(fontSize: 12)),
                                Text('Patient: ${widget.verifiedPrescription!['patient_name']}', style: const TextStyle(fontSize: 12)),
                                Text('Diagnosis: ${widget.verifiedPrescription!['diagnosis']}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Medicines list
                  Expanded(
                    child: _matchedMedicines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'No medicines found in database',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Try uploading a clearer prescription image',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _matchedMedicines.length,
                            itemBuilder: (context, index) {
                              final medicine = _matchedMedicines[index];
                              final isSelected = _selectedMedicines.contains(medicine);
                              final confidence = medicine['confidence_score'] ?? 0.0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) => _toggleMedicineSelection(medicine),
                                    activeColor: const Color(0xFF1E90FF),
                                  ),
                                  title: Text(
                                    medicine['name'] ?? 'Unknown Medicine',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('₹${medicine['price'] ?? 'N/A'}'),
                                      Text(
                                        'Stock: ${medicine['stock_quantity'] ?? 0} ${medicine['unit'] ?? 'units'}',
                                        style: TextStyle(
                                          color: (medicine['stock_quantity'] ?? 0) > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      if (confidence > 0)
                                        Text(
                                          'Match: ${(confidence * 100).round()}%',
                                          style: TextStyle(
                                            color: confidence > 0.8
                                                ? Colors.green
                                                : confidence > 0.6
                                                    ? Colors.orange
                                                    : Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? const Color(0xFF1E90FF) : Colors.grey,
                                  ),
                                  onTap: () => _toggleMedicineSelection(medicine),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom action bar
                  if (_matchedMedicines.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_selectedMedicines.length} of ${_matchedMedicines.length} selected',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _selectedMedicines.isEmpty ? null : _findGenericAlternatives,
                            icon: const Icon(Icons.lightbulb_outline),
                            label: const Text('Generic Alternatives'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E90FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _selectedMedicines.isEmpty ? null : _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
