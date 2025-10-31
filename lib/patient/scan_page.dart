import 'package:flutter/material.dart';
import '../app_router.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? _imagePath;

  // TODO: Replace placeholder with real image picking logic
  void _pickImageFromCamera() {
    setState(() {
      // Simulate image pick by assigning local asset or file path
      _imagePath = 'assets/placeholder_rx.png';
    });
  }

  void _pickImageFromGallery() {
    setState(() {
      _imagePath = 'assets/placeholder_rx.png';
    });
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.teal),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.teal),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() => _imagePath = null);
  }

  void _proceedToReview() {
    if (_imagePath != null) {
      Navigator.pushNamed(context, AppRoutes.ocrReview);
      // Ideally pass image path or data as argument if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.teal; // Use your app’s main color

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Prescription", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _imagePath == null
                  ? _UploadPlaceholder(onTap: _showImageSourceOptions, primary: primary)
                  : _ImagePreview(imagePath: _imagePath!, onRemove: _removeImage),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _imagePath == null ? null : _proceedToReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Continue"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upload placeholder with dashed border
class _UploadPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final Color primary;
  const _UploadPlaceholder({required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: primary.withOpacity(0.6), width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
          color: primary.withOpacity(0.05),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 80, color: primary.withOpacity(0.8)),
                const SizedBox(height: 16),
                Text("Tap to Upload", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                const SizedBox(height: 8),
                Text(
                  "Take a photo or choose from gallery",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Preview with floating change button
class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _ImagePreview({required this.imagePath, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.teal;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: primary.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: onRemove,
            ),
          ),
        ),
      ],
    );
  }
}
