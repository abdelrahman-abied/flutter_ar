import 'package:flutter/material.dart';

class Zoom extends StatefulWidget {
  const Zoom({super.key});

  @override
  State<Zoom> createState() => _ZoomState();
}

class _ZoomState extends State<Zoom> {
  double _counter = 0;
  double _previousScale = 1.0;
  double _scaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoom'),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scaleFactor;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          if (details.scale != 1.0) {
            if (details.scale > _previousScale && _counter < 100) {
              _counter += 1; // Increase counter by 10%
              debugPrint("ScaleUpdateDetails: ${_counter}");
              debugPrint("ScaleUpdateDetails: ${_counter * 1.1}");
            } else if (details.scale < _previousScale && _counter > 0) {
              _counter -= 1; // Decrease counter by 10%
            }
            _previousScale = details.scale;
            setState(() {});
          }
        },
        child: Container(
          color: Colors.amber,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Text('$_counter %'),
          ),
        ),
      ),
    );
  }
}
