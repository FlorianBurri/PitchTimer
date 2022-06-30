import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashscreenView extends StatefulWidget {
  final Widget child;
  const SplashscreenView({required this.child, Key? key}) : super(key: key);

  @override
  State<SplashscreenView> createState() => _SplashscreenViewState();
}

class _SplashscreenViewState extends State<SplashscreenView> {
  late Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    _currentWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Pitch Timer",
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
        ),
        LottieBuilder.asset(
          "assets/lotties/kitty.json",
          repeat: false,
          onLoaded: (_) => Future.delayed(const Duration(seconds: 2), () {
            setState(() => _currentWidget = widget.child);
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentWidget,
        ),
      ),
    );
  }
}
