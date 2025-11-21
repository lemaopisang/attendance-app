import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('attendance');
  final Random _random = Random();

  void _editData(
    String docId,
    String currentName,
    String currentAddress,
    String currentDescription,
    String currentDatetime,
  ) {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);
    final descriptionController = TextEditingController(text: currentDescription);
    final datetimeController = TextEditingController(text: currentDatetime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: Text(
          'Edit Data',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField('Name', nameController),
              _buildInputField('Address', addressController),
              _buildInputField('Description', descriptionController),
              _buildInputField('Datetime', datetimeController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dataCollection.doc(docId).update({
                'name': nameController.text,
                'address': addressController.text,
                'description': descriptionController.text,
                'datetime': datetimeController.text,
              });
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Save', style: GoogleFonts.inter(color: Colors.cyanAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        title: Text(
          'Delete Data',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this data?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dataCollection.doc(docId).delete();
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Yes', style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: GoogleFonts.inter(color: Colors.white70)),
          ),
        ],
      ),
    );
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
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: dataCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'Ups, there is no data!',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      final data = snapshot.data!.docs;
                      return ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (_, separatorIndex) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final doc = data[index];
                          return _buildHistoryCard(
                            doc.id,
                            doc['name'],
                            doc['address'],
                            doc['description'],
                            doc['datetime'],
                          ).animate().fadeIn(duration: 350.ms, delay: (index * 40).ms);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                  'Attendance History',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Review and manage today’s submissions.',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    String docId,
    String name,
    String address,
    String description,
    String datetime,
  ) {
    final color = Colors.primaries[
      _random.nextInt(Colors.primaries.length)
    ];

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
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.shade200, color.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildMetaRow('Address', address),
                    _buildMetaRow('Description', description),
                    _buildMetaRow('Timestamp', datetime),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    color: Colors.cyanAccent,
                    onTap: () => _editData(docId, name, address, description, datetime),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    onTap: () => _deleteData(docId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5)),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(color: Colors.white),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
