import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'book_appointment.dart';
import 'services/api_client.dart';

class DoctorDetails extends StatefulWidget {
  final String vetId;
  final String name;
  final String specialty;
  // Server-relative path like "/uploads/..." or null when no photo is set.
  final String? photoPath;
  final String clinicLocation;
  final String description;
  final String fee;
  final String startTime;
  final String endTime;

  const DoctorDetails({
    super.key,
    required this.vetId,
    required this.name,
    required this.specialty,
    this.photoPath,
    required this.clinicLocation,
    required this.description,
    required this.fee,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  ImageProvider _resolvePhoto() {
    final p = widget.photoPath;
    if (p == null || p.isEmpty) return const AssetImage('assets/images/vet1.png');
    if (p.startsWith('http')) return NetworkImage(p);
    return NetworkImage('${ApiClient.baseUrl}$p');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookAppointment(
                          vetId: widget.vetId,
                          doctorName: widget.name,
                          photoPath: widget.photoPath,
                          fee: widget.fee,
                          startTime: widget.startTime,
                          endTime: widget.endTime,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7578),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Appointment',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image(image: _resolvePhoto(), fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.specialty,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: const Color(0xFFFF7578),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Color(0xFFFF7578), size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.clinicLocation,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'About',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.grey[600],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
