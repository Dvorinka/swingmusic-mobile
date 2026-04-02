import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerScreen extends StatefulWidget {
  const MobileScannerScreen({super.key});

  @override
  State<MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State<MobileScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  String? _capturedCode;

  @override
  void initState() {
    super.initState();
    controller.start();

    controller.barcodes.listen((capture) {
      if (capture.barcodes.isNotEmpty && _isScanning) {
        final barcode = capture.barcodes.first;
        if (barcode.rawValue != null) {
          setState(() {
            _isScanning = false;
            _capturedCode = barcode.rawValue!;
          });

          // Stop scanning after successful capture
          controller.stop();

          // Return the scanned code and close the screen
          if (mounted) {
            Navigator.of(context).pop(barcode.rawValue);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isScanning)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _isScanning = true;
                  _capturedCode = null;
                });
                controller.start();
              },
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Stack(
            children: [
              MobileScanner(
                controller: controller,
              ),
              _buildScannerOverlay(),
            ],
          ),

          // Scanning indicator
          if (_isScanning)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Scanning for QR code...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Captured code display
          if (_capturedCode != null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'QR Code Scanned!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _capturedCode!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(_capturedCode);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Use This Code'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isScanning = true;
                              _capturedCode = null;
                            });
                            controller.start();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Scan Again'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        // Dark overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),

        // Scanning window (transparent square)
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 3),
            ),
          ),
        ),

        // Corner markers
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              children: [
                // Top-left corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.green, width: 3),
                        left: BorderSide(color: Colors.green, width: 3),
                      ),
                    ),
                  ),
                ),
                // Top-right corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.green, width: 3),
                        right: BorderSide(color: Colors.green, width: 3),
                      ),
                    ),
                  ),
                ),
                // Bottom-left corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.green, width: 3),
                        left: BorderSide(color: Colors.green, width: 3),
                      ),
                    ),
                  ),
                ),
                // Bottom-right corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.green, width: 3),
                        right: BorderSide(color: Colors.green, width: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instructions
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: const Text(
            'Align QR code within the frame to scan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
