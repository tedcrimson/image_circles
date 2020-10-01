import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class Circle extends StatefulWidget {
  final img.Image image;

  final int power;
  final bool recurse;
  final double size;
  final double x;
  final double y;
  final Stream<Offset> pointerStream;
  final bool shape;
  Circle(this.image,
      {@required this.power,
      @required this.pointerStream,
      @required this.recurse,
      @required this.size,
      this.x = 0,
      this.y = 0,
      this.shape = false});
  @override
  _CircleState createState() => _CircleState();
}

class _CircleState extends State<Circle> {
  bool recurse = false;

  StreamSubscription<Offset> listener;
  Rect rect;
  @override
  void initState() {
    super.initState();
    rect = Rect.fromLTWH(widget.x, widget.y, widget.size, widget.size);
    listener = widget.pointerStream.listen((event) {
      if (rect.contains(event)) {
        setState(() {
          recurse = true;
        });
        listener.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (recurse && widget.recurse)
      return Row(
          children: List.generate(
              2,
              (i) => Expanded(
                    child: Column(
                        children: List.generate(
                      2,
                      (j) => Expanded(
                          child: Circle(
                        widget.image,
                        power: widget.power * 2,
                        pointerStream: widget.pointerStream,
                        x: widget.x + i * widget.size / 2,
                        y: widget.y + j * widget.size / 2,
                        size: widget.size / 2,
                        recurse: widget.power <= 64,
                        shape: widget.shape,
                      )),
                    )),
                  )));
    else {
      Rect rect = Rect.fromLTWH(
        widget.x,
        widget.y,
        widget.size,
        widget.size,
      );
      // print("Power:$power => $rect");

      return Container(
        decoration: BoxDecoration(
          color: _getAverageColor(widget.image, rect),
          shape: widget.shape ? BoxShape.circle : BoxShape.rectangle,
        ),
      );
    }
  }

  Color _getAverageColor(img.Image bitmap, Rect rect) {
    // return Colors.orange;
    int redBucket = 0;
    int greenBucket = 0;
    int blueBucket = 0;
    int pixelCount = 0;

    int startY = rect.top.toInt();
    int startX = rect.left.toInt();
    for (int y = startY; y < startY + rect.height; y++) {
      for (int x = startX; x < startX + rect.width; x++) {
        // if (y > bitmap.height) {
        //   continue;
        // }
        // print("$x:$y");
        int c = bitmap.getPixel(x, y);

        pixelCount++;
        redBucket += img.getRed(c);
        greenBucket += img.getGreen(c);
        blueBucket += img.getBlue(c);
      }
    }

    Color averageColor =
        Color.fromRGBO(redBucket ~/ pixelCount, greenBucket ~/ pixelCount, blueBucket ~/ pixelCount, 1);
    return averageColor;
  }
}
