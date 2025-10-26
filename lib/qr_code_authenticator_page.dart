import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class QRCodeAuthenticatorPage extends StatefulWidget {
  final File prescriptionImage;

  const QRCodeAuthenticatorPage({super.key, required this.prescriptionImage});

  @override
  _QRCodeAuthenticatorPageState createState() => _QRCodeAuthenticatorPageState();
}

class _QRCodeAuthenticatorPageState extends State<QRCodeAuthenticatorPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isVerifying = false;
  Map<String, dynamic>? _verifiedPrescription;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-start scanning
    _startScanning();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _verifiedPrescription = null;
      _errorMessage = null;
    });
  }

  Future<void> _verifyQRCode(String qrData) async {
    setState(() {
      _isVerifying = true;
      _isScanning = false;
    });

    try {
      // Decode the QR data
      final decodedData = utf8.decode(base64Decode(qrData));
      final prescriptionData = jsonDecode(decodedData);

      // Verify prescription in database
      final response = await SupabaseClientManager.client
          .from('prescriptions')
          .select('*')
          .eq('id', prescriptionData['id'])
          .eq('status', 'active')
          .single();

      final dbPrescription = response;

      // Check if prescription is expired
      final expiresAt = DateTime.parse(dbPrescription['expires_at']);
      if (expiresAt.isBefore(DateTime.now())) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Prescription has expired';
        });
        return;
      }

      // Verify QR data matches database
      if (dbPrescription['qr_data'] != qrData) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'QR code data does not match prescription records';
        });
        return;
      }

      setState(() {
        _isVerifying = false;
        _verifiedPrescription = {
          ...dbPrescription,
          'decodedData': prescriptionData,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Invalid QR code or prescription not found: $e';
      });
    }
  }

  void _proceedWithVerifiedPrescription() {
    if (_verifiedPrescription != null) {
      // Navigate back to OCR results with verified prescription data
      Navigator.pop(context, _verifiedPrescription);
    }
  }

  void _skipVerification() {
    // Allow user to proceed without QR verification
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Prescription QR'),
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
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
        child: Column(
          children: [
            // Camera preview area
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isScanning ? const Color(0xFF1E90FF) : Colors.grey,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: _isScanning
                      ? MobileScanner(
                          controller: cameraController,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                _verifyQRCode(barcode.rawValue!);
                                break;
                              }
                            }
                          },
                        )
                      : Container(
                          color: Colors.black.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // Status and results area
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isScanning) ...[
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Scan Prescription QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Point your camera at the QR code on the prescription',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (_isVerifying) ...[
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Verifying Prescription...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ] else if (_verifiedPrescription != null) ...[
                      Icon(
                        Icons.verified,
                        size: 60,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Prescription Verified!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ID: ${_verifiedPrescription!['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _proceedWithVerifiedPrescription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Continue with OCR'),
                      ),
                    ] else if (_errorMessage != null) ...[
                      Icon(
                        Icons.error,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Verification Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _startScanning,
                              child: const Text('Try Again'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _skipVerification,
                              child: const Text('Skip Verification'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom info
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'QR Code Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E90FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan the QR code on your prescription to verify its authenticity and ensure medicine safety',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _skipVerification,
                    child: const Text(
                      'Continue without verification',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
