import 'dart:ui';

import 'package:attendance_app/ui/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  final List<String> categoriesList = <String>[
    "Please Choose:",
    "Others",
    "Permission",
    "Sick",
  ];

  final TextEditingController controllerName = TextEditingController();
  double dLat = 0.0, dLong = 0.0;
  final CollectionReference<Map<String, dynamic>> dataCollection =
    FirebaseFirestore.instance.collection('attendance');

  int dateHours = 0, dateMinutes = 0;
  String dropValueCategories = "Please Choose:";
  final TextEditingController fromController = TextEditingController();
  String strAlamat = '', strDate = '', strTime = '', strDateTime = '';
  final TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  //show progress dialog
  void showLoaderDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
              ),
              const SizedBox(width: 16),
              Text(
                'Processing your request…',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  //submit data absent to firebase
  Future<void> submitAbsen(
    String nama,
    String keterangan,
    String from,
    String until,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // Validasi input sebelum mengirim ke Firebase
    if (nama.isEmpty ||
        keterangan == "Please Choose:" ||
        from.isEmpty ||
        until.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Pastikan semua data telah diisi!",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Menampilkan loader
    showLoaderDialog(context);

    try {
      await dataCollection.add({
        'address': '-',
        'name': nama,
        'description': keterangan,
        'datetime': '$from - $until',
        'created_at': FieldValue.serverTimestamp(), // Tambahkan timestamp
      });

      if (!mounted) return;
      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Yeay! Attendance Report Succeeded!",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali ke halaman utama
      await navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Ups, terjadi kesalahan: $e",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
  body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permission Request',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Need to take a leave or submit a permission? Let us know below.',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 450.ms).slideY(begin: .08),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Your Name'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controllerName,
                      style: GoogleFonts.inter(color: Colors.white),
                      cursorColor: Colors.cyanAccent,
                      decoration: _inputDecoration('Tell us who is requesting'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 480.ms).slideY(begin: .08, delay: 40.ms),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: dropValueCategories,
                      dropdownColor: const Color(0xFF12121C),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: _inputDecoration('Select a reason'),
                      items: categoriesList
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.inter(color: Colors.white)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => dropValueCategories = value);
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: .08, delay: 60.ms),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Date Range'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            controller: fromController,
                            hint: 'Start date',
                            icon: Icons.calendar_today,
                            onTap: () => _pickDate(fromController),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDateField(
                            controller: toController,
                            hint: 'End date',
                            icon: Icons.event,
                            onTap: () => _pickDate(toController),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 520.ms).slideY(begin: .08, delay: 80.ms),
              const SizedBox(height: 24),
              _buildSubmitButton(context),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission Menu',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Absence form for special requests',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.2),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controllerName.text.isEmpty ||
            dropValueCategories == "Please Choose:" ||
            fromController.text.isEmpty ||
            toController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Ups, please fill the form!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.blueGrey,
              behavior: SnackBarBehavior.floating,
              shape: StadiumBorder(),
            ),
          );
          return;
        }
        submitAbsen(
          controllerName.text.trim(),
          dropValueCategories,
          fromController.text,
          toController.text,
        );
      },
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8800D9F5),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Make a Request',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ).animate().scale(duration: 520.ms, curve: Curves.easeOutBack),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
  final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00D9F5),
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0F0C29),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.cyanAccent),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd MMM yyyy').format(pickedDate);
    }
  }
}
