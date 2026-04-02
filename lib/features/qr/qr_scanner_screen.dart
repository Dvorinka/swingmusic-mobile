import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedCode;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
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
          IconButton(
            onPressed: () => _toggleFlash(),
            icon: Icon(
              _controller.value.torchState == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scanned Result Display
          if (_scannedCode != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Scanned Code:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scannedCode!,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _useScannedCode,
                          child: const Text('Use'),
                        ),
                        ElevatedButton(
                          onPressed: _resetScanner,
                          child: const Text('Scan Again'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Scanning Frame with Animation
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: _QRScannerPainter(),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_scannedCode == null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Position QR code within the frame to scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null && _scannedCode == null) {
        setState(() {
          _scannedCode = barcode.rawValue!;
        });

        // Provide haptic feedback
        HapticFeedback.lightImpact();

        break;
      }
    }
  }

  void _toggleFlash() {
    _controller.toggleTorch();
  }

  void _resetScanner() {
    setState(() {
      _scannedCode = null;
    });
    _controller.start();
  }

  void _useScannedCode() {
    if (_scannedCode != null) {
      Navigator.of(context).pop(_scannedCode);
    }
  }
}

class _QRScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final cornerLength = 20.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QRScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.borderLength = 30.0,
    this.borderRadius = 0.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect, textDirection: textDirection), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path outerPath = Path()..addRect(rect);
    Path cutOut = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
    return Path.combine(PathOperation.difference, outerPath, cutOut);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final center = rect.center;
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Draw corner pieces
    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
        ..quadraticBezierTo(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + borderRadius,
          cutOutRect.top,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top),
      paint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
        ..quadraticBezierTo(
          cutOutRect.right,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + borderRadius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.top + borderLength),
      paint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right, cutOutRect.bottom - borderLength)
        ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
        ..quadraticBezierTo(
          cutOutRect.right,
          cutOutRect.bottom,
          cutOutRect.right - borderRadius,
          cutOutRect.bottom,
        )
        ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom),
      paint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom)
        ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom)
        ..quadraticBezierTo(
          cutOutRect.left,
          cutOutRect.bottom,
          cutOutRect.left,
          cutOutRect.bottom - borderRadius,
        )
        ..lineTo(cutOutRect.left, cutOutRect.bottom - borderLength),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderLength: borderLength * t,
      borderRadius: borderRadius * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
