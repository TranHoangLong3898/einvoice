import 'package:flutter/material.dart';

class PageNotFound extends StatefulWidget {
  const PageNotFound({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageNotFoundState();
}

class _PageNotFoundState extends State<PageNotFound>
    with SingleTickerProviderStateMixin {
  final RelativeRectTween _relativeRectTween = RelativeRectTween(
    begin: const RelativeRect.fromLTRB(24, 24, 24, 200),
    end: const RelativeRect.fromLTRB(24, 24, 24, 250),
  );
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popAndPushNamed(context, 'landing');
            },
          ),
        ),
        backgroundColor: const Color(0xffd8f3dc),
        body: Stack(
          children: [
            PositionedTransition(
              rect: _relativeRectTween.animate(_controller),
              child: Image.asset('assets/img/logo.png'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 1.5,
              bottom: 0,
              left: 24,
              right: 24,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '404',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 50,
                        letterSpacing: 2,
                        color: Color(0xff2f3640),
                        fontFamily: 'Anton',
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Sorry, we couldn\'t find the page!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff2f3640),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
