import 'dart:ui';

import 'package:attendance_app/ui/absent/absent_screen.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/ui/attendance/attendance_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: .85,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _DashboardCard(
                        title: 'Check In',
                        subtitle: 'Face capture',
                        asset: 'assets/images/ic_absen.png',
                        gradientColors: const [Color(0xFF00F5A0), Color(0xFF00D9F5)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AttendScreen(),
                            ),
                          );
                        },
                      ),
                      _DashboardCard(
                        title: 'Permission',
                        subtitle: 'Submit request',
                        asset: 'assets/images/ic_leave.png',
                        gradientColors: const [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AbsentScreen(),
                            ),
                          );
                        },
                      ),
                      _DashboardCard(
                        title: 'History',
                        subtitle: 'Review summary',
                        asset: 'assets/images/ic_history.png',
                        gradientColors: const [Color(0xFF845EC2), Color(0xFFD65DB1)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _DashboardCard(
                        title: 'Live Camera',
                        subtitle: 'Capture selfie',
                        asset: 'assets/images/ic_absen.png',
                        gradientColors: const [Color(0xFF2AF598), Color(0xFF009EFD)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AttendScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: .1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Portal',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Neon glass dashboard for quick daily actions.',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 450.ms).slideY(begin: -.1);
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.gradientColors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String asset;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: gradientColors
                    .map((c) => c.withValues(alpha: 0.22))
                    .toList(growable: false),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.last.withValues(alpha: 0.4),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      asset,
                      height: 36,
                      width: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 2200.ms, delay: 400.ms),
    );
  }
}
