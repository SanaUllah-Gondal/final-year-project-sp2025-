// import 'package:flutter/material.dart';

// class DashboardCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final VoidCallback? onTap; // ✅ Add this parameter

//   const DashboardCard({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.color,
//     this.onTap, // ✅ Accept it in the constructor
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: onTap, // ✅ Use the passed onTap
//         borderRadius: BorderRadius.circular(12),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 48, color: color),
//               SizedBox(height: 10),
//               Text(title, style: TextStyle(fontSize: 18)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  DashboardCard({
    required this.title,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              offset: Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
