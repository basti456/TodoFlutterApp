import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // Semi-transparent background
        Opacity(
          opacity: 0.5, // Adjust the opacity as needed
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black, // Background color
          ),
        ),
        // Centered CircularProgressIndicator
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
