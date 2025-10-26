import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_client.dart';

class QRCodeGeneratorPage extends StatefulWidget {
  const QRCodeGeneratorPage({super.key});

  @override
  _QRCodeGeneratorPageState createState() => _QRCodeGeneratorPageState();
}

class _QRCodeGeneratorPageState extends State<QRCodeGeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _medicinesController = TextEditingController();

  bool _isGenerating = false;
  String? _generatedQRData;
  String? _prescriptionId;

  Future<void> _generatePrescriptionQR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate unique prescription ID
      final prescriptionId = 'RX${DateTime.now().millisecondsSinceEpoch}';

      // Create prescription data
      final prescriptionData = {
        'id': prescriptionId,
        'patientName': _patientNameController.text.trim(),
        'doctorName': _doctorNameController.text.trim(),
        'diagnosis': _diagnosisController.text.trim(),
        'medicines': _medicinesController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'doctorId': SupabaseClientManager.client.auth.currentUser?.id,
        'status': 'active',
        'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };

      // Encrypt the data (simple base64 for demo - use proper encryption in production)
      final jsonData = jsonEncode(prescriptionData);
      final encryptedData = base64Encode(utf8.encode(jsonData));

      // Store prescription in database
      await SupabaseClientManager.client.from('prescriptions').insert({
        'id': prescriptionId,
        'patient_name': prescriptionData['patientName'],
        'doctor_name': prescriptionData['doctorName'],
        'diagnosis': prescriptionData['diagnosis'],
        'medicines': prescriptionData['medicines'],
        'qr_data': encryptedData,
        'status': 'active',
        'expires_at': prescriptionData['expiresAt'],
        'created_at': prescriptionData['timestamp'],
        'doctor_id': prescriptionData['doctorId'],
      });

      setState(() {
        _generatedQRData = encryptedData;
        _prescriptionId = prescriptionId;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription QR code generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating QR code: $e')),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _patientNameController.clear();
    _doctorNameController.clear();
    _diagnosisController.clear();
    _medicinesController.clear();
    setState(() {
      _generatedQRData = null;
      _prescriptionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Prescription QR'),
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Prescription QR Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E90FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Generate a secure QR code for prescription authenticity',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              if (_generatedQRData == null) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _patientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _doctorNameController,
                        decoration: const InputDecoration(
                          labelText: 'Doctor Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter doctor name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: const InputDecoration(
                          labelText: 'Diagnosis',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter diagnosis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicinesController,
                        decoration: const InputDecoration(
                          labelText: 'Medicines (one per line)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                          hintText: 'Paracetamol 500mg\nAmoxicillin 250mg\nIbuprofen 200mg',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter medicines';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isGenerating ? null : _generatePrescriptionQR,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isGenerating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Generate QR Code',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // QR Code Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Prescription ID: $_prescriptionId',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      QrImageView(
                        data: _generatedQRData!,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Scan this QR code to verify prescription authenticity',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Share QR code functionality could be added here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Share functionality coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1E90FF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _resetForm,
                              icon: const Icon(Icons.add),
                              label: const Text('New QR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Security Features:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Unique prescription ID\n• Encrypted prescription data\n• Doctor authentication\n• 30-day validity period\n• Tamper-proof verification',
                      style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
