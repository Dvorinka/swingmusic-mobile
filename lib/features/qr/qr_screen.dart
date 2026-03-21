import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../app/state/session_controller.dart';
import 'mobile_scanner_screen.dart';

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
                        : _qrCode.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No QR Code',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : QrImageView(
                                data: _qrCode,
                                version: QrVersions.auto,
                                size: 180.0,
                                backgroundColor: Colors.white,
                                dataModuleStyle: QrDataModuleStyle(
                                  color: Colors.black,
                                ),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_scanner),
                              SizedBox(width: 8),
                              Text('Scan QR Code'),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code),
                              SizedBox(width: 8),
                              Text('Generate QR'),
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

  void _generateQRCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Get current auth token and server info
      final session = Provider.of<SessionController>(context, listen: false);
      
      if (session.isAuthenticated) {
        // Generate QR code with auth token and server URL
        final qrData = {
          'token': 'current_user_token', // In real implementation, get from secure storage
          'serverUrl': session.baseUrl,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'app': 'swingmusic_mobile',
        };
        
        setState(() {
          _qrCode = Uri.encodeComponent(qrData.toString());
          _isGenerating = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code generated!')),
          );
        }
      } else {
        throw Exception('Not authenticated');
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate QR code: ${e.toString()}')),
        );
      }
    }
  }

  void _scanQRCode() async {
    try {
      // Use mobile_scanner for real QR code scanning
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MobileScannerScreen(),
        ),
      );
      
      if (result != null && result is String) {
        setState(() {
          _isScanning = false;
          _qrCode = result;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code scanned!')),
          );
        }
      } else {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: ${e.toString()}')),
        );
      }
    }
  }

  void _connectWithQR() async {
    if (_qrCode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter or scan a QR code')),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final session = Provider.of<SessionController>(context, listen: false);
      
      // Parse QR code data
      String qrData = _qrCode;
      if (_qrCode.startsWith('SWING-') || _qrCode.startsWith('DEMO-')) {
        // Handle legacy/demo codes
        qrData = _qrCode.replaceFirst(RegExp(r'^(SWING-|DEMO-SCANNED-)'), '');
      }
      
      // Try to decode if it's URI encoded
      try {
        qrData = Uri.decodeComponent(qrData);
      } catch (e) {
        // Not URI encoded, use as is
      }
      
      // Connect using QR data
      if (qrData.isNotEmpty) {
        // Parse QR data format: "server_url|pair_code"
        final parts = qrData.split('|');
        if (parts.length == 2) {
          await session.loginWithPairCode(serverUrl: parts[0], code: parts[1]);
        }
        
        setState(() {
          _isGenerating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connected with QR Code!')),
          );

          // Navigate to main app
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } else {
        throw Exception('Invalid QR code format');
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: ${e.toString()}')),
        );
      }
    }
  }
}
