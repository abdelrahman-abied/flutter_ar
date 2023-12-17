import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveProgressIndicator extends StatelessWidget {
  final double? value;

   const AdaptiveProgressIndicator({Key? key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return const CupertinoActivityIndicator();
    }
    if (value == null) {
      return const CircularProgressIndicator();
    }
    return CircularProgressIndicator(
      value: value,
    );
  }
}
