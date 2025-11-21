import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/utils/face_detection/google_ml_kit.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _State();
}

class _State extends State<CameraScreen> with TickerProviderStateMixin {
  //set face detection
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      enableLandmarks: true,
    ),
  );

  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  //set open front camera device
  //if 1 front, if 0 rear
  Future<void> loadCamera() async {
    cameras = await availableCameras();

    if (cameras != null) {
      // Pilih kamera depan (front)
      final frontCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      controller = CameraController(frontCamera, ResolutionPreset.veryHigh);

      try {
        await controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.camera_enhance_outlined, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Ups, camera not found!",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          shape: StadiumBorder(),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: _buildCameraSurface(),
                  ),
                ),
              ),
              Positioned.fill(child: IgnorePointer(child: _buildLensOverlay())),
              _buildHeader(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildControlPanel(size),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //permission location
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Location services are disabled. Please enable the services.",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          shape: StadiumBorder(),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      print("Layanan lokasi tidak aktif, silakan aktifkan GPS.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_off, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Location permission denied.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.blueGrey,
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Location permission denied forever, we cannot access.",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          shape: StadiumBorder(),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  //face detection
  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (mounted) {
      setState(() {
        Navigator.of(context).pop(true);
        if (faces.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AttendScreen(image: image)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.face_retouching_natural_outlined,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Ups, make sure that you're face is clearly visible!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blueGrey,
              shape: StadiumBorder(),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  Widget _buildCameraSurface() {
    if (controller == null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          'Ups, camera error!',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (!controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller!),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x66000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLensOverlay() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Lottie.asset(
        'assets/raw/face_id_ring.json',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 12,
      left: 20,
      right: 20,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture Selfie',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Align your face within the neon ring',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(Size size) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6600D9F5),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find a bright spot and keep your head steady.",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We’ll check for a clear face before moving on.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 22),
                Center(child: _buildCaptureButton()),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _handleCapture,
      child: Container(
        width: 84,
        height: 84,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x8800D9F5),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.camera, color: Colors.black, size: 32),
      )
          .animate()
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.easeInOutCubic,
          )
          .shimmer(duration: 2500.ms),
    );
  }

  Future<void> _handleCapture() async {
    final hasPermission = await handleLocationPermission();
    try {
      if (controller == null || !controller!.value.isInitialized) {
        return;
      }

      await controller!.setFlashMode(FlashMode.off);
      final shot = await controller!.takePicture();
      setState(() => image = shot);

      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please allow the permission first!',
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
        return;
      }

      _showLoaderDialog();
      final inputImage = InputImage.fromFilePath(shot.path);
      if (Platform.isAndroid) {
        await processImage(inputImage);
      } else {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendScreen(image: image),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

  void _showLoaderDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
            const SizedBox(width: 18),
            Text(
              'Checking the data...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
