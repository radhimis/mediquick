import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += line.text + '\n';
        }
      }

      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  Future<List<Map<String, dynamic>>> extractMedicinesFromPrescription(String prescriptionText) async {
    List<Map<String, dynamic>> medicines = [];

    // Split text into lines
    List<String> lines = prescriptionText.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty && _isLikelyMedicineName(line)) {
        // Parse medicine details
        Map<String, dynamic> medicineInfo = _parseMedicineLine(line);
        if (medicineInfo['name'] != null) {
          medicines.add(medicineInfo);
        }
      }
    }

    return medicines;
  }

  Map<String, dynamic> _parseMedicineLine(String line) {
    Map<String, dynamic> medicine = {
      'name': null,
      'dosage': null,
      'frequency': null,
      'duration': null,
      'quantity': null,
      'confidence': 0.0
    };

    line = line.trim();

    // Extract dosage (e.g., "500mg", "10ml", "200mcg")
    RegExp dosageRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(mg|g|ml|mcg|iu|units?)', caseSensitive: false);
    Match? dosageMatch = dosageRegex.firstMatch(line);
    if (dosageMatch != null) {
      medicine['dosage'] = dosageMatch.group(0);
      medicine['confidence'] += 0.3;
    }

    // Extract form (tablet, capsule, syrup, etc.)
    RegExp formRegex = RegExp(r'\b(tablet|capsule|syrup|injection|ointment|cream|drops|solution|suspension)\b', caseSensitive: false);
    Match? formMatch = formRegex.firstMatch(line);
    if (formMatch != null) {
      medicine['form'] = formMatch.group(0);
      medicine['confidence'] += 0.2;
    }

    // Extract frequency (e.g., "twice daily", "3 times a day", "OD", "BD", "TDS")
    RegExp freqRegex = RegExp(r'\b(\d+)\s*(times?|x)\s*(daily|a day|day)|(\b(OD|BD|TDS|QID|once|twice|thrice)\b)', caseSensitive: false);
    Match? freqMatch = freqRegex.firstMatch(line);
    if (freqMatch != null) {
      medicine['frequency'] = freqMatch.group(0);
      medicine['confidence'] += 0.2;
    }

    // Extract duration (e.g., "7 days", "2 weeks", "1 month")
    RegExp durationRegex = RegExp(r'(\d+)\s*(days?|weeks?|months?)', caseSensitive: false);
    Match? durationMatch = durationRegex.firstMatch(line);
    if (durationMatch != null) {
      medicine['duration'] = durationMatch.group(0);
      medicine['confidence'] += 0.2;
    }

    // Extract medicine name (remove dosage, frequency, duration from line)
    String medicineName = line
        .replaceAll(dosageRegex, '')
        .replaceAll(formRegex, '')
        .replaceAll(freqRegex, '')
        .replaceAll(durationRegex, '')
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();

    if (medicineName.isNotEmpty && medicineName.length > 2) {
      medicine['name'] = medicineName;
      medicine['confidence'] += 0.3;
    }

    return medicine;
  }

  bool _isLikelyMedicineName(String text) {
    text = text.toLowerCase();

    // Skip common non-medicine words
    List<String> skipWords = [
      'prescription', 'doctor', 'patient', 'date', 'signature', 'take', 'times',
      'daily', 'morning', 'evening', 'night', 'before', 'after', 'meals', 'food',
      'days', 'weeks', 'months', 'years', 'age', 'sex', 'address', 'phone',
      'diagnosis', 'symptoms', 'notes', 'instructions', 'hospital', 'clinic',
      'regd', 'registration', 'license', 'dr.', 'mr.', 'mrs.', 'ms.'
    ];

    for (String skipWord in skipWords) {
      if (text.contains(skipWord)) {
        return false;
      }
    }

    // Look for medicine-like patterns
    if (RegExp(r'\d+(mg|g|ml|mcg|iu|units?)').hasMatch(text) ||
        RegExp(r'(tablet|capsule|syrup|injection|ointment|cream|drops)').hasMatch(text) ||
        RegExp(r'\b(OD|BD|TDS|QID)\b').hasMatch(text) ||
        text.length > 3 && text.length < 100) {
      return true;
    }

    return false;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
