import 'package:flutter/material.dart';

/// Mock camera capture screen
/// In production, this would use image_picker package
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  String? _capturedImagePath;
  bool _flashEnabled = false;

  void _capturePhoto() {
    // Mock capture - in production would use image_picker.pickImage(source: ImageSource.camera)
    setState(() {
      _capturedImagePath = 'mock://captured-photo-${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  void _pickFromGallery() {
    // Mock gallery picker - in production would use image_picker.pickImage(source: ImageSource.gallery)
    setState(() {
      _capturedImagePath = 'mock://gallery-photo-${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  void _retake() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  void _confirmPhoto() {
    if (_capturedImagePath != null) {
      Navigator.pop(context, _capturedImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Recipe'),
        actions: [
          if (_capturedImagePath == null)
            IconButton(
              icon: Icon(_flashEnabled ? Icons.flash_on : Icons.flash_off),
              onPressed: () {
                setState(() {
                  _flashEnabled = !_flashEnabled;
                });
              },
              tooltip: 'Toggle flash',
            ),
        ],
      ),
      body: Center(
        child: _capturedImagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera preview would appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera),
                    label: const Text('Capture Photo'),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Captured Image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _retake,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _confirmPhoto,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
