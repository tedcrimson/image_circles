import 'package:flutter/material.dart';
import 'package:image_circles/utils/const.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final Color color;
  final Color backgroundColor;
  const LoadingWidget({this.size, this.color = mainColor, this.backgroundColor});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        backgroundColor: backgroundColor ?? Color(0xFFDFDFE4),
        // strokeWidth: .0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    ));
  }
}
