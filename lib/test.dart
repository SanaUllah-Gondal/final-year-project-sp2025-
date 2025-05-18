// import 'package:flutter/material.dart';

// class PlumberPage extends StatelessWidget {
//   final String imageUrl = "http://192.168.100.108:8000/uploads/plumber_image/";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Image')),
//       body: Center(
//         child: Image.network(
//           imageUrl,
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return CircularProgressIndicator();
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return Text('Failed to load image.');
//           },
//         ),
//       ),
//     );
//   }
// }
