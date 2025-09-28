import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Booking your appointment...'),
          SizedBox(height: 8),
          Text('Please wait...', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}