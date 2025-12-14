import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../screens/home_screen.dart';
import '../screens/incident_log_screen.dart';
import '../screens/service_locator_screen.dart';
import '../screens/resources_screen.dart';
import '../screens/first_response_screen.dart';

class BottomNavigation extends StatelessWidget {
  final String currentRoute;

  const BottomNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Home',
                isActive: currentRoute == '/home',
                onTap: () {
                  if (currentRoute != '/home') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.description,
                label: 'Records',
                isActive: currentRoute == '/records',
                onTap: () {
                  if (currentRoute != '/records') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const IncidentLogScreen()),
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.location_on,
                label: 'Services',
                isActive: currentRoute == '/services',
                onTap: () {
                  if (currentRoute != '/services') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ServiceLocatorScreen()),
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.info,
                label: 'Resources',
                isActive: currentRoute == '/resources',
                onTap: () {
                  if (currentRoute != '/resources') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ResourcesScreen()),
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.medical_services,
                label: 'First Response',
                isActive: currentRoute == '/first-response',
                onTap: () {
                  if (currentRoute != '/first-response') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FirstResponseScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? AppConstants.primaryColor : AppConstants.textSecondaryColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

