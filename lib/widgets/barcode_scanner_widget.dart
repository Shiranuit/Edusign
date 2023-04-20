import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

import 'barcode_area_painter.dart';

enum ScanState {
  beforeFirstScan,
  firstScan,
  afterFirstScan,
}

enum AnimationScanState {
  waiting,
  success,
  failure,
  processing,
}

class Notifier extends ChangeNotifier {
  notify() {
    notifyListeners();
  }
}

class BarcodeScannerAnimationController {
  Completer _processing = Completer();

  BarcodeScannerAnimationController() {
    _processing.complete();
  }

  /// Needs to be called when started animating
  void start(Function? callback) {
    if (!_processing.isCompleted) {
      _processing.complete();
    }
    _processing = Completer();
    callback?.call();
  }

  /// Needs to be called when the animation is done
  void stop() {
    if (!_processing.isCompleted) {
      _processing.complete();
    }
  }

  Future get processing => _processing.future;
}

class BarcodeScanner extends StatefulWidget {
  /// Callback called each a barcode is scanned
  FutureOr<bool> Function(Barcode)? onScan;

  /// Delay beetween each scan
  /// [null] means no delay
  /// Default: [null]
  final Duration? scanDelay;

  /// Widget used to optimize rendering
  Widget? child;

  /// Build a widget at the center of the scanner
  /// Used to animate the scanner when Idle, Processing, Success, Failure
  Widget? Function(BuildContext, ScanState, AnimationScanState,
      BarcodeScannerAnimationController, Widget?)? builder;

  /// Called after the the Success Animation
  final void Function()? afterSuccessAnimation;

  /// Called after the failure animation
  final void Function()? afterFailureAnimation;

  /// Vibrate each time a code is scanned
  bool hapticFeedback;

  /// Allow scanning the same barcode multiple times
  bool allowDuplicates;

  /// Force the indicator to be displayed as a square
  bool squareIndicator;

  /// Determine if the torch can be switched on or off
  bool torchSwitcheable;

  /// Determine if the camera can be switched between front and back
  bool cameraSwitcheable;

  BarcodeScanner({
    Key? key,
    this.onScan,
    this.scanDelay,
    this.builder,
    this.child,
    this.afterSuccessAnimation,
    this.afterFailureAnimation,
    this.hapticFeedback = true,
    this.allowDuplicates = false,
    this.squareIndicator = false,
    this.torchSwitcheable = true,
    this.cameraSwitcheable = true,
  }) : super(key: key);

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Color areaColor = Colors.orange;
  late MobileScannerController? _controller;
  late ValueNotifier<ScanState> _scanState;
  late ValueNotifier<AnimationScanState> _animationState;
  final Notifier _notifier = Notifier();
  final BarcodeScannerAnimationController _animationController =
      BarcodeScannerAnimationController();

  @override
  void initState() {
    _scanState = ValueNotifier(ScanState.beforeFirstScan);
    _animationState = ValueNotifier(AnimationScanState.waiting);

    _scanState.addListener(() {
      _notifier.notify();
    });
    _animationState.addListener(() {
      _notifier.notify();
    });

    _controller = MobileScannerController();
    super.initState();
  }

  @override
  void dispose() {
    _scanState.dispose();
    _animationState.dispose();
    _controller!.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.stop();
    }
    _controller?.start();
  }

  void _onBarcodeDetected(
    Barcode barcode,
    MobileScannerArguments? arguments,
  ) async {
    if (_animationState.value != AnimationScanState.waiting) {
      return;
    }

    _animationState.value = AnimationScanState.processing;
    bool success = await Future.value(widget.onScan!(barcode));
    if (_scanState.value == ScanState.beforeFirstScan) {
      _scanState.value = ScanState.firstScan;
    } else {
      _scanState.value = ScanState.afterFirstScan;
    }
    if (success) {
      _animationState.value = AnimationScanState.success;
      setState(() {
        areaColor = Colors.green;
      });
      if (widget.hapticFeedback) {
        HapticFeedback.vibrate();
      }
    } else {
      _animationState.value = AnimationScanState.failure;
      setState(() {
        areaColor = Colors.red;
      });
      if (widget.hapticFeedback) {
        HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 50));
        HapticFeedback.vibrate();
      }
    }
    await Future.delayed(widget.scanDelay ?? const Duration(seconds: 0));
    await _animationController.processing;
    _animationState.value = AnimationScanState.waiting;
    setState(() {
      areaColor = Colors.orange;
    });
    if (success) {
      widget.afterSuccessAnimation?.call();
    } else {
      widget.afterFailureAnimation?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MobileScanner(
        key: qrKey,
        controller: _controller,
        onDetect: _onBarcodeDetected,
        allowDuplicates: widget.allowDuplicates,
      ),
      FractionallySizedBox(
        heightFactor: 1,
        widthFactor: 1,
        child: CustomPaint(
          painter: BarcodeAreaPainter(
            color: areaColor,
            outsideOpacity: 0.5,
            makeSquare: widget.squareIndicator,
          ),
        ),
      ),
      Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: AnimatedBuilder(
            animation: _notifier,
            builder: (context, child) {
              return widget.builder?.call(
                    context,
                    _scanState.value,
                    _animationState.value,
                    _animationController,
                    widget.child,
                  ) ??
                  Container();
            },
          ),
        ),
      ),
      SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.cameraSwitcheable)
              IconButton(
                icon: const Icon(Icons.flip_camera_android),
                onPressed: () {
                  _controller!.switchCamera();
                },
              ),
            ValueListenableBuilder(
              valueListenable: _controller!.torchState,
              builder: (context, value, child) {
                return IconButton(
                  icon: value == TorchState.on
                      ? Icon(Icons.flash_on)
                      : Icon(Icons.flash_off),
                  onPressed: () {
                    _controller!.toggleTorch();
                  },
                );
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
