import 'package:flutter/material.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
