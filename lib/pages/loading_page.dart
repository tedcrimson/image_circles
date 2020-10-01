import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_circles/utils/const.dart';
import 'package:image_circles/widgets/loading_widget.dart';
import 'package:image_circles/widgets/my_button.dart';

typedef String LoadError(PlatformException e);

class LoadingPage<T> extends StatefulWidget {
  LoadingPage({
    this.onLoad,
    this.onTimeout,
    this.onError,
    this.duration,
    this.margin,
    this.loadingSize = 80,
    this.backgroundColor = Colors.white70,
  });

  final Color backgroundColor;
  final int duration;
  final double loadingSize;
  final EdgeInsets margin;
  final LoadError onError;
  final VoidCallback onTimeout;

  @override
  _LoadingPageState createState() => _LoadingPageState();

  final Future<T> Function() onLoad;
}

class _LoadingPageState extends State<LoadingPage> {
  bool _error = false;
  String _errorText = "error";
  bool _timeout = false;
  int _tryAgainCount = 0;
  int _tryMaxAgainCount = 3;

  bool _success = false;

  @override
  void initState() {
    super.initState();
    if (widget.onLoad != null) {
      _load();
    }
  }

  String get timeoutText => 'timeout';

  String get tryAgainText => 'try_again';

  _load() {
    _startLoading();
    _stopLoading();
  }

  _startLoading() async {
    _timeout = false;
    _error = false;
    var result;
    try {
      result = await widget.onLoad();
      _success = true;
    } catch (e) {
      if (widget.onError != null) {
        _errorText = widget.onError(e);
      } else {
        if (e is PlatformException) _errorText = e.message;
      }
      setState(() {
        _error = true;
      });
      return;
      // result = e;
    }
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  _stopLoading() async {
    await Future.delayed(Duration(seconds: widget.duration));
    if (this.mounted && !_error) {
      if (widget.onTimeout != null) widget.onTimeout();
      setState(() {
        _timeout = true;
      });
      // if (mounted) Navigator.of(context).pop();
    }
  }

  _drawCard(List<Widget> widgets) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        // heightFactor: 0.5,
        child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 10,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: widgets),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(widget.onLoad == null),
      child: Stack(children: [
        Positioned.fill(
          child: Container(color: widget.backgroundColor),
        ),
        if (_timeout && !_success)
          // Center(child: MyCard(child: Text(timeoutText)))
          _drawCard(
            <Widget>[
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  timeoutText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  Icons.wifi,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MyButton(
                tryAgainText,
                backgroundColor: mainColor,
                onPressed: () {
                  setState(() {
                    _tryAgainCount++;
                    _load();
                  });
                },
              ),
              if (_tryAgainCount >= _tryMaxAgainCount)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MyButton(
                    'close',
                    backgroundColor: mainColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
            ],
          )
        else if (_error && !_success)
          _drawCard(
            <Widget>[
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  _errorText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  Icons.error,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: MyButton(
                  'close',
                  backgroundColor: mainColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          )
        else
          Center(
            child: Padding(
              padding: widget.margin ?? EdgeInsets.zero,
              child: LoadingWidget(
                size: widget.loadingSize,
                backgroundColor: const Color(0xFFDFDFE4),
              ),
            ),
          )
      ]),
    );
  }
}
