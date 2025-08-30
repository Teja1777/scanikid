import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  
  final MobileScannerController _scannerController = MobileScannerController(
    
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isScanCompleted = false;

  @override
  void dispose() {
    
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          
          IconButton(
            onPressed: () => _scannerController.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
          
          IconButton(
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          
          MobileScanner(
            controller: _scannerController,
            
            onDetect: (capture) {
              
              if (!_isScanCompleted) {
                _isScanCompleted = true;
                final String code = capture.barcodes.first.rawValue ?? '---';
                
                Navigator.pop(context, code);
              }
            },
          ),
          
          Positioned.fill(
            child: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: const Color(0xFF6366F1),
                  borderRadius: 12,
                  borderLength: 24,
                  borderWidth: 8,
                  cutOutSize: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Place QR code in the frame to scan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double cutOutSize;
  final double borderRadius;
  final double borderLength;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 5.0,
    this.cutOutSize = 250.0,
    this.borderRadius = 0.0,
    this.borderLength = 20.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.top + borderLength)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + borderLength, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right - borderLength, rect.top) 
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.top + borderLength)
      ..lineTo(
        rect.right,
        rect.bottom - borderLength,
      ) 
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right - borderLength, rect.bottom)
      ..lineTo(
        rect.left + borderLength,
        rect.bottom,
      ) 
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.bottom - borderLength)
      ..lineTo(rect.left, rect.top + borderLength)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final top = (height - cutOutSize) / 2;
    final left = (width - cutOutSize) / 2;

    final backgroundPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(left, top, cutOutSize, cutOutSize);

    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(rect),
          Path()..addRRect(
            RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          ),
        ),
        backgroundPaint,
      )
      ..drawPath(getOuterPath(cutOutRect), borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}