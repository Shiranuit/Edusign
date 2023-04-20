import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

class SignaturePage extends StatefulWidget {
  String? signature;
  SignaturePage({Key? key}) : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late HandSignatureControl _controller;

  @override
  void initState() {
    _controller = HandSignatureControl(
      threshold: 5,
      smoothRatio: 0.65,
      velocityRange: 1.0,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() async {
    var image =
        await _controller.toPicture(width: 400, height: 200)?.toImage(400, 200);
    if (image != null) {
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        String base64 = convert.base64Encode(pngBytes);
        Navigator.pop(context, base64);
        return;
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                    child: HandSignature(
                      control: _controller,
                      color: Colors.black,
                      type: SignatureDrawType.shape,
                      width: 5.0,
                      maxWidth: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          )
        ],
      ),
    );
  }
}
