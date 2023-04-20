import 'package:edusign_v2/models/course_model.dart';
import 'package:edusign_v2/services/edusign_service.dart';
import 'package:edusign_v2/services/signature_service.dart';
import 'package:edusign_v2/services/storage_service.dart';
import 'package:edusign_v2/widgets/animated_validator.dart';
import 'package:edusign_v2/widgets/barcode_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CourseScannerPage extends StatefulWidget {
  Course course;
  CourseScannerPage({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<CourseScannerPage> createState() => _CourseScannerPageState();
}

class _CourseScannerPageState extends State<CourseScannerPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool shouldPop = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    super.initState();
  }

  Future<bool> _onScan(Barcode barcode) async {
    if (barcode.rawValue != null) {
      String? signature = await StorageService.read(key: 'signature');

      try {
        bool result = await EdusignService.validateCourse(
          EdusignService.user!,
          widget.course,
          barcode.rawValue!,
          signature ?? SignatureService.defaultSignture,
        );

        Course course = await EdusignService.getCourseById(
            EdusignService.user!, widget.course.id);
        widget.course.updateFrom(course);

        if (result) {
          shouldPop = true;
        }

        return result;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BarcodeScanner(
        onScan: _onScan,
        afterSuccessAnimation: () {
          Navigator.pop(context);
        },
        allowDuplicates: true,
        scanDelay: const Duration(seconds: 1),
        squareIndicator: true,
        builder: (context, state, animationState, barcodeAnimationController,
            child) {
          if (animationState == AnimationScanState.waiting) {
            return const FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: Text(
                  'QR Code',
                ),
              ),
            );
          } else if (animationState == AnimationScanState.processing) {
            return const FractionallySizedBox(
              widthFactor: 0.8,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),
              ),
            );
          } else if (animationState == AnimationScanState.success) {
            barcodeAnimationController.start(() {
              _controller.forward().whenComplete(() async {
                await Future.delayed(const Duration(milliseconds: 500));
                _controller.reverse().whenComplete(() {
                  barcodeAnimationController.stop();
                });
              });
            });
            return FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: AnimatedValidator(
                  icon: ValidatorIcon.check,
                  controller: _controller,
                  size: 60,
                  color: Colors.green,
                ),
              ),
            );
          } else {
            barcodeAnimationController.start(() {
              _controller.forward().whenComplete(() async {
                await Future.delayed(const Duration(milliseconds: 500));
                _controller.reverse().whenComplete(() {
                  barcodeAnimationController.stop();
                });
              });
            });
            return FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: AnimatedValidator(
                  icon: ValidatorIcon.cross,
                  controller: _controller,
                  size: 60,
                  color: Colors.red,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
