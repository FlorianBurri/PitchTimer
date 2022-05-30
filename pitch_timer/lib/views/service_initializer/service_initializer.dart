import 'package:flutter/material.dart';

class ServiceInitializer extends StatelessWidget {
  final Widget child;
  final List<Future> initializers;
  const ServiceInitializer({required this.child, required this.initializers, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(initializers),
      builder: ((context, snapshot) {
        if (ConnectionState.done != snapshot.connectionState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("An error occurred: ${snapshot.error}"),
          );
        }
        return child;
      }),
    );
  }
}
