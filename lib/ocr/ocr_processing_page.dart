import 'dart:io';
import 'package:flutter/material.dart';
import 'ocr_service.dart';
import 'ocr_results_page.dart';

class OCRProcessingPage extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic>? verifiedPrescription;

  const OCRProcessingPage({
    super.key,
    required this.imageFile,
    this.verifiedPrescription,
  });

  @override
  _OCRProcessingPageState createState() => _OCRProcessingPageState();
}

class _OCRProcessingPageState extends State<OCRProcessingPage> {
  late OCRService _ocrService;
  bool _isProcessing = true;
  String _extractedText = '';
  List<Map<String, dynamic>> _medicines = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _ocrService = OCRService();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // If we have verified prescription data, use it directly
      if (widget.verifiedPrescription != null) {
        final verifiedData = widget.verifiedPrescription!;
        _extractedText = 'Verified Prescription: ${verifiedData['medicines']}';

        // Parse medicines from verified prescription
        final medicinesList = verifiedData['medicines'].toString().split('\n');
        _medicines = medicinesList.map((medicine) => {
          'name': medicine.trim(),
          'dosage': null,
          'frequency': null,
          'duration': null,
          'quantity': null,
          'confidence': 1.0, // 100% confidence for verified prescriptions
        }).toList();

        setState(() {
          _isProcessing = false;
        });

        // Navigate to results page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OCRResultsPage(
              extractedText: _extractedText,
              medicines: _medicines,
              imageFile: widget.imageFile,
              verifiedPrescription: widget.verifiedPrescription,
            ),
          ),
        );
        return;
      }

      // Original OCR processing logic
      _extractedText = await _ocrService.extractTextFromImage(widget.imageFile);

      if (_extractedText.isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No text found in the image. Please try with a clearer prescription image.';
        });
        return;
      }

      // Extract medicines from text
      _medicines = await _ocrService.extractMedicinesFromPrescription(_extractedText);

      setState(() {
        _isProcessing = false;
      });

      // Navigate to results page
      if (_medicines.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OCRResultsPage(
              extractedText: _extractedText,
              medicines: _medicines,
              imageFile: widget.imageFile,
              verifiedPrescription: null,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'No medicines could be identified. Please try with a different image or enter medicines manually.';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image: $e';
      });
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Prescription'),
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image preview
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                if (_isProcessing) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Analyzing prescription...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E90FF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Extracting text and identifying medicines',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_errorMessage.isNotEmpty) ...[
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Processing Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E90FF),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1E90FF)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF1E90FF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
