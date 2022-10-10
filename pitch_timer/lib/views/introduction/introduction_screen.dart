import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class AppIntroductionScreen extends StatelessWidget {
  PageViewModel getAnimatedPage(String title, String imagePath) {
    return PageViewModel(
      title: title,
      bodyWidget: Center(
        child: Material(
          elevation: 4,
          child: Image.asset(
            imagePath,
            height: 600,
          ),
        ),
      ),
    );
  }

  final _listPagesViewModel = <PageViewModel>[
    PageViewModel(
      title: "Welcome to the Pitch Timer App!",
      body:
          """When the time is limited, it is key to use every second wisely. This app will help you plan and manage your time.""",
      image: Center(
        child: Image.asset(
          "assets/images/title.png",
          height: 200,
        ),
      ),
    ),
  ];

  AppIntroductionScreen({Key? key}) : super(key: key) {
    _listPagesViewModel.add(
        getAnimatedPage("Tap a chapter to edit", "assets/animations/EditChapter_50_short.gif"));
    _listPagesViewModel.add(
        getAnimatedPage("Longpress to change the order", "assets/animations/ReoderChapter_50.gif"));
    _listPagesViewModel.add(getAnimatedPage(
        "Shortcut to change chapter duration", "assets/animations/DragChapterDuration_30.gif"));
    _listPagesViewModel
        .add(getAnimatedPage("Swipe left to delete", "assets/animations/DeleteChapter_50.gif"));
  }

  void _onIntroEnd(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _listPagesViewModel,
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () => _onIntroEnd(context),
      showBackButton: false,
      showSkipButton: true,
      showNextButton: true,
      globalBackgroundColor: Theme.of(context).colorScheme.tertiary,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.navigate_next),
      //done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
    ); //Mat
  }
}
