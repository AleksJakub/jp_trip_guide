import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/image1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 60),
                _buildMenuCard(
                  context,
                  'Emergency',
                  'Emergency contacts and information',
                  Icons.sos,
                  Colors.grey.shade700,
                  () => context.go('/emergency'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  'Transport Help',
                  'Transportation information for cities',
                  Icons.directions_bus,
                  Colors.grey.shade600,
                  () => context.go('/transport-help'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  'Cultural Tips',
                  'Learn about Japanese culture',
                  Icons.lightbulb_outline,
                  Colors.grey.shade500,
                  () => context.go('/cultural-tips'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  'Live Events',
                  'Current events and festivals',
                  Icons.event_available,
                  Colors.grey.shade600,
                  () => context.go('/live-events'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  'Travel Wallet',
                  'Manage your travel expenses',
                  Icons.account_balance_wallet,
                  Colors.grey.shade500,
                  () => context.go('/travel-wallet'),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  'Profile',
                  'Edit your profile and settings',
                  Icons.person,
                  Colors.grey.shade700,
                  () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


