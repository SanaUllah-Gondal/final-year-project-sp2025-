import 'package:flutter/material.dart';
import 'package:plumber_project/widgets/custom_badge.dart';

class PlumberDashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool showBadge;
  final int? badgeCount;

  const PlumberDashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 140,
        maxHeight: 140,
      ),
      child: Stack(
        children: [
          // Main Card
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon with white circle background
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Badge for pending requests
          if (showBadge && badgeCount != null && badgeCount! > 0)
            Positioned(
              top: 12,
              right: 12,
              child: CustomBadge(
                count: badgeCount!,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                size: 24,
                fontSize: 10,
                child: SizedBox.shrink(),
              ),
            ),

          // Ripple effect
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}