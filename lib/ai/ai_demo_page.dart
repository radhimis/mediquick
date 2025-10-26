import 'package:flutter/material.dart';
import 'generic_alternatives_page.dart';

class AIDemoPage extends StatefulWidget {
  const AIDemoPage({super.key});

  @override
  _AIDemoPageState createState() => _AIDemoPageState();
}

class _AIDemoPageState extends State<AIDemoPage> {
  final TextEditingController _medicineController = TextEditingController();
  final List<String> _medicines = [];

  final List<String> _sampleMedicines = [
    'Lipitor',
    'Viagra',
    'Singulair',
    'Nexium',
    'Plavix',
    'Advil',
    'Tylenol',
    'Zocor',
    'Cozaar',
  ];

  void _addMedicine() {
    final medicine = _medicineController.text.trim();
    if (medicine.isNotEmpty && !_medicines.contains(medicine)) {
      setState(() {
        _medicines.add(medicine);
        _medicineController.clear();
      });
    }
  }

  void _removeMedicine(String medicine) {
    setState(() {
      _medicines.remove(medicine);
    });
  }

  void _addSampleMedicine(String medicine) {
    if (!_medicines.contains(medicine)) {
      setState(() {
        _medicines.add(medicine);
      });
    }
  }

  void _findAlternatives() {
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericAlternativesPage(medicines: _medicines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Generic Alternatives Demo'),
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E90FF), Color(0xFF00BFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 AI Generic Alternatives',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find FDA-approved generic alternatives and save money on your prescriptions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Add Medicine Section
            const Text(
              'Add Medicines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Manual Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _medicineController,
                    decoration: InputDecoration(
                      hintText: 'Enter medicine name (e.g., Lipitor)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addMedicine(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sample Medicines
            const Text(
              'Quick Add (Sample Medicines):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sampleMedicines.map((medicine) => ActionChip(
                label: Text(medicine),
                onPressed: () => _addSampleMedicine(medicine),
                backgroundColor: Colors.blue.shade50,
              )).toList(),
            ),

            const SizedBox(height: 30),

            // Selected Medicines
            if (_medicines.isNotEmpty) ...[
              const Text(
                'Selected Medicines:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ..._medicines.map((medicine) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.medical_services, color: Color(0xFF1E90FF)),
                  title: Text(medicine),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeMedicine(medicine),
                  ),
                ),
              )),
            ],

            const SizedBox(height: 30),

            // Find Alternatives Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _medicines.isEmpty ? null : _findAlternatives,
                icon: const Icon(Icons.search),
                label: Text('Find Generic Alternatives (${_medicines.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Info Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'About Generic Alternatives',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '• Generic medicines contain the same active ingredients as brand-name drugs\n'
                      '• They are FDA-approved and meet the same quality standards\n'
                      '• Generics typically cost 80-95% less than brand-name drugs\n'
                      '• They work the same way and provide the same clinical benefits',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }
}
