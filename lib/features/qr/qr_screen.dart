import 'package:flutter/material.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String _qrCode = '';
  bool _isGenerating = false;
  bool _isScanning = false;
  final TextEditingController _qrController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Pairing'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Code Display
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2.0,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QR Code Pairing',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan or generate a QR code to connect',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // QR Code Visual
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2.0,
                      ),
                    ),
                    child: _isGenerating
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 180,
                                height: 180,
                                color: Colors.black,
                                child: const Center(
                                  child: Text(
                                    'QR CODE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _qrCode.isEmpty ? 'Generate QR Code' : _qrCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isScanning ? null : _toggleScanning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.qr_code_scanner),
                              const SizedBox(width: 8),
                              const Text('Scan QR Code'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isScanning ? null : _generateQRCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.qr_code),
                              const SizedBox(width: 8),
                              const Text('Generate QR'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Manual Entry
                  TextField(
                    controller: _qrController,
                    decoration: InputDecoration(
                      labelText: 'Or enter QR code manually',
                      hintText: 'Enter QR code',
                      prefixIcon: const Icon(Icons.keyboard),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _qrCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Connect Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _qrCode.isEmpty ? null : _connectWithQR,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Connect'),
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

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
    
    if (_isScanning) {
      _scanQRCode();
    }
  }

  void _generateQRCode() {
    setState(() {
      _isGenerating = true;
    });

    // Generate a random QR code for demo
    Future.delayed(const Duration(seconds: 2)).then((_) {
      setState(() {
        _isGenerating = false;
        _qrCode = 'SWING-${DateTime.now().millisecondsSinceEpoch % 10000}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code generated!')),
      );
    });
  }

  void _scanQRCode() async {
    try {
      // In a real app, this would use camera plugin
      // For demo, we'll simulate scanning
      await Future.delayed(const Duration(seconds: 3));
      
      setState(() {
        _isScanning = false;
        _qrCode = 'DEMO-SCANNED-${DateTime.now().millisecondsSinceEpoch}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code scanned!')),
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: ${e.toString()}')),
      );
    }
  }

  void _connectWithQR() async {
    if (_qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan a QR code')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate connection with QR code
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected with QR Code!')),
      );

      // Navigate to main app
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: ${e.toString()}')),
      );
    }
  }
}
