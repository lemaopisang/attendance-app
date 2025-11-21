import 'dart:io';
import 'dart:ui';

import 'package:attendance_app/ui/attend/camera_screen.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;

  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState();
}

class _AttendScreenState extends State<AttendScreen> {
  late final CollectionReference<Map<String, dynamic>> dataCollection;
  final TextEditingController controllerName = TextEditingController();

  XFile? _image;
  bool isLoading = false;

  double dLat = 0;
  double dLong = 0;

  String strAlamat = '';
  String strDate = '';
  String strTime = '';
  String strDateTime = '';
  String strStatus = 'Attend';

  int dateHours = 0;
  int dateMinutes = 0;

  @override
  void initState() {
    super.initState();
    dataCollection = FirebaseFirestore.instance.collection('attendance');
    _image = widget.image;
    setDateTime();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final allowed = await handleLocationPermission();
      if (!mounted) return;
      if (allowed) {
        setState(() => isLoading = true);
        await getGeoLocationPosition();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AttendScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image?.path != oldWidget.image?.path) {
      setState(() => _image = widget.image);
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    super.dispose();
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
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Capture Selfie',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined,
                              color: Colors.white, size: 22),
                          onPressed: _openCamera,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _openCamera,
                      child: AnimatedContainer(
                        duration: 400.ms,
                        curve: Curves.easeOutQuad,
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: _image == null
                              ? const LinearGradient(
                                  colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AnimatedSwitcher(
                            duration: 350.ms,
                            child: _image == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
              Icon(Icons.face_retouching_natural,
                color: Colors.white.withValues(alpha: 0.8),
                                              size: 38)
                                          .animate()
                                          .scale(duration: 600.ms, curve: Curves.easeInOut)
                                          .shakeY(delay: 800.ms),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tap to capture selfie',
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Image.file(
                                    File(_image!.path),
                                    key: ValueKey(_image!.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: .1),
              const SizedBox(height: 20),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Name',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controllerName,
                      style: GoogleFonts.inter(color: Colors.white),
                      cursorColor: Colors.cyanAccent,
                      decoration: _inputDecoration('Please enter your name'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 520.ms).slideY(begin: .1, delay: 80.ms),
              const SizedBox(height: 20),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Location',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final allowed = await handleLocationPermission();
                            if (!allowed || !mounted) return;
                            setState(() => isLoading = true);
                            await getGeoLocationPosition();
                          },
                          icon: Icon(
                            Icons.my_location,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: 400.ms,
                      child: isLoading
                          ? const SizedBox(
                              height: 40,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            )
                          : Text(
                              strAlamat.isEmpty
                                  ? 'Fetching address...'
                                  : strAlamat,
                              key: ValueKey(strAlamat),
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 540.ms).slideY(begin: .1, delay: 120.ms),
              const SizedBox(height: 28),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
      filled: true,
  fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.2),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Attendance',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                strDateTime.isEmpty ? 'Initializing...' : strDateTime,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_image == null || controllerName.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Please capture a selfie and fill your name.',
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
        submitAbsen(strAlamat, controllerName.text.trim(), strStatus);
      },
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8800D9F5),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Report Now',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  Future<void> getGeoLocationPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      if (!mounted) return;
      setState(() {
        dLat = position.latitude;
        dLong = position.longitude;
      });
      await getAddressFromLongLat(position);
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> getAddressFromLongLat(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty || !mounted) return;
      final place = placemarks.first;
      setState(() {
        strAlamat =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Unable to fetch address: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_off, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Location services are disabled. Please enable them.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueGrey,
            behavior: SnackBarBehavior.floating,
            shape: StadiumBorder(),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Location permission denied.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blueGrey,
              behavior: SnackBarBehavior.floating,
              shape: StadiumBorder(),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_off, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Location permission denied forever.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueGrey,
            behavior: SnackBarBehavior.floating,
            shape: StadiumBorder(),
          ),
        );
      }
      return false;
    }
    return true;
  }

  void _showLoaderDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
  backgroundColor: Colors.black.withValues(alpha: 0.8),
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
            const SizedBox(width: 18),
            Text(
              'Saving attendance…',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void setDateTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    setState(() {
      strDate = dateFormat.format(now);
      strTime = timeFormat.format(now);
      strDateTime = "$strDate | $strTime";
      dateHours = now.hour;
      dateMinutes = now.minute;
      strStatus = _deriveStatus(dateHours, dateMinutes);
    });
  }

  String _deriveStatus(int hours, int minutes) {
    if (hours < 8 || (hours == 8 && minutes <= 30)) {
      return 'Attend';
    }
    if ((hours > 8 && hours < 18) || (hours == 8 && minutes > 30)) {
      return 'Late';
    }
    return 'Leave';
  }

  Future<void> submitAbsen(
    String alamat,
    String nama,
    String status,
  ) async {
    _showLoaderDialog();
    try {
      await dataCollection.add({
        'address': alamat,
        'name': nama,
        'description': status,
        'datetime': strDateTime,
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Attendance report submitted successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: StadiumBorder(),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ups, $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
        ),
      );
    }
  }
}
