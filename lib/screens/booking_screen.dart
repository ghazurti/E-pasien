import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_epasien/blocs/auth/auth_bloc.dart';
import 'package:flutter_epasien/blocs/auth/auth_state.dart';
import 'package:flutter_epasien/blocs/booking/booking_bloc.dart';
import 'package:flutter_epasien/blocs/booking/booking_event.dart';
import 'package:flutter_epasien/blocs/booking/booking_state.dart';
import 'package:flutter_epasien/blocs/jadwal/jadwal_bloc.dart';
import 'package:flutter_epasien/blocs/jadwal/jadwal_event.dart';
import 'package:flutter_epasien/blocs/jadwal/jadwal_state.dart';
import 'package:flutter_epasien/config/theme.dart';
import 'package:flutter_epasien/models/booking.dart';
import 'package:flutter_epasien/models/jadwal.dart';

class BookingScreen extends StatefulWidget {
  final Jadwal? selectedJadwal;

  const BookingScreen({super.key, this.selectedJadwal});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedPoliCode;
  String? _selectedDokterCode;
  String _selectedCaraBayar = 'BPJ';

  final List<Map<String, String>> _caraBayarList = [
    {'code': 'BPJ', 'name': 'BPJS'},
    {'code': 'UMU', 'name': 'Umum / Mandiri'},
  ];

  @override
  void initState() {
    super.initState();
    final jadwalState = context.read<JadwalBloc>().state;
    if (jadwalState is JadwalInitial) {
      context.read<JadwalBloc>().add(LoadJadwal());
    }
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDokterCode = null;
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showSnack('Pilih tanggal periksa terlebih dahulu', isError: true);
      return;
    }

    if (_selectedPoliCode == null || _selectedDokterCode == null) {
      _showSnack('Pilih Poliklinik dan Dokter terlebih dahulu', isError: true);
      return;
    }

    if (_selectedCaraBayar == 'BPJ') {
      _showBpjsRujukanDialog();
      return;
    }

    _proceedBooking();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showBpjsRujukanDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _BpjsRujukanDialog(),
    );
    if (!mounted) return;

    switch (result) {
      case 'bpjs':
        _proceedBooking();
      case 'umum':
        setState(() => _selectedCaraBayar = 'UMU');
        _proceedBooking();
      case 'puskesmas':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Kunjungi Puskesmas atau Dokter Praktek terdekat untuk mendapatkan surat rujukan BPJS',
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
    }
  }

  void _proceedBooking() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final request = CreateBookingRequest(
        noRkmMedis: authState.pasien.noRkmMedis,
        tanggalPeriksa: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        kdPoli: _selectedPoliCode!,
        kdDokter: _selectedDokterCode!,
        kdPj: _selectedCaraBayar,
        keluhan: _keluhanController.text.trim(),
      );
      context.read<BookingBloc>().add(CreateBookingEvent(request: request));
    }
  }

  IconData _poliIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('anak')) return Icons.child_care_rounded;
    if (n.contains('gigi')) return Icons.medication_rounded;
    if (n.contains('mata')) return Icons.visibility_rounded;
    if (n.contains('jantung') || n.contains('kardio')) return Icons.favorite_rounded;
    if (n.contains('bedah')) return Icons.healing_rounded;
    if (n.contains('kulit')) return Icons.face_rounded;
    if (n.contains('paru') || n.contains('dalam')) return Icons.air_rounded;
    if (n.contains('saraf')) return Icons.psychology_rounded;
    if (n.contains('kandungan') || n.contains('obgyn')) return Icons.pregnant_woman_rounded;
    if (n.contains('tht')) return Icons.hearing_rounded;
    return Icons.local_hospital_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Booking Poli',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: BlocBuilder<JadwalBloc, JadwalState>(
          builder: (context, jadwalState) {
            if (jadwalState is JadwalInitial || jadwalState is JadwalLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            if (jadwalState is JadwalError) {
              return _buildErrorState(jadwalState.message);
            }

            if (jadwalState is JadwalLoaded) {
              final List<Jadwal> allJadwal = jadwalState.jadwalList;
              final Map<String, String> poliMap = {};
              for (var j in allJadwal) {
                poliMap[j.kdPoli] = j.nmPoli;
              }
              final List<String> poliCodes = poliMap.keys.toList();

              String? selectedDayName;
              if (_selectedDate != null) {
                const dayNames = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'AKHAD'];
                selectedDayName = dayNames[_selectedDate!.weekday - 1];
              }

              List<Jadwal> doctorsInPoli = [];
              if (_selectedPoliCode != null) {
                doctorsInPoli = allJadwal.where((j) {
                  if (j.kdPoli != _selectedPoliCode) return false;
                  if (selectedDayName != null) {
                    return j.hariKerja.toUpperCase() == selectedDayName;
                  }
                  return true;
                }).toList();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info jam pendaftaran
                      _buildInfoCard(),
                      const SizedBox(height: 16),

                      // Form card
                      _buildFormCard(poliCodes, poliMap, doctorsInPoli),
                      const SizedBox(height: 16),

                      // Submit button
                      BlocBuilder<BookingBloc, BookingState>(
                        builder: (context, state) {
                          final isLoading = state is BookingLoading;
                          return SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _handleSubmit,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_rounded, size: 20),
                              label: Text(
                                isLoading ? 'Memproses...' : 'Konfirmasi Booking',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildErrorState('Gagal memuat data jadwal');
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Text(
                'Jam Pendaftaran Poli',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _JamRow(hari: 'Senin – Kamis', jam: '08:00 – 12:00'),
          const SizedBox(height: 4),
          const _JamRow(hari: "Jum'at", jam: '08:00 – 11:00'),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFBFDBFE)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://wa.me/6282292595705');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Row(
              children: const [
                Icon(Icons.chat_rounded, size: 15, color: Color(0xFF25D366)),
                SizedBox(width: 6),
                Text(
                  '+62 822-9259-5705',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '(WhatsApp)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF25D366),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    List<String> poliCodes,
    Map<String, String> poliMap,
    List<Jadwal> doctorsInPoli,
  ) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
    );

    InputDecoration fieldDecor({
      required String label,
      required IconData icon,
      String? hint,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: focusedBorder,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Jadwal Kunjungan', icon: Icons.event_rounded),
          const SizedBox(height: 12),

          // Tanggal
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDate != null
                      ? AppTheme.primaryColor.withValues(alpha: 0.5)
                      : Colors.grey[200]!,
                  width: _selectedDate != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Pilih tanggal periksa'
                          : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null ? Colors.grey[400] : const Color(0xFF1E293B),
                        fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _SectionLabel(label: 'Pilih Poli & Dokter', icon: Icons.local_hospital_rounded),
          const SizedBox(height: 12),

          // Poli dropdown
          DropdownButtonFormField<String>(
            value: _selectedPoliCode,
            isExpanded: true,
            decoration: fieldDecor(label: 'Poliklinik', icon: Icons.local_hospital_rounded),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: poliCodes.map((code) {
              final name = poliMap[code]!;
              return DropdownMenuItem<String>(
                value: code,
                child: Row(
                  children: [
                    Icon(_poliIcon(name), size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPoliCode = value;
                _selectedDokterCode = null;
              });
            },
            validator: (value) => value == null ? 'Pilih poliklinik' : null,
          ),
          const SizedBox(height: 12),

          // Dokter dropdown
          DropdownButtonFormField<String>(
            value: _selectedDokterCode,
            isExpanded: true,
            decoration: fieldDecor(
              label: 'Dokter',
              icon: Icons.person_rounded,
              hint: _selectedDate == null
                  ? 'Pilih tanggal dahulu'
                  : _selectedPoliCode == null
                      ? 'Pilih poliklinik dahulu'
                      : doctorsInPoli.isEmpty
                          ? 'Tidak ada dokter hari ini'
                          : null,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: doctorsInPoli.map((j) {
              return DropdownMenuItem<String>(
                value: j.kdDokter,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Icon(Icons.person_rounded, size: 14, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        j.nmDokter,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (_selectedDate == null || _selectedPoliCode == null)
                ? null
                : (value) => setState(() => _selectedDokterCode = value),
            validator: (value) => value == null ? 'Pilih dokter' : null,
          ),
          const SizedBox(height: 20),

          _SectionLabel(label: 'Cara Pembayaran', icon: Icons.payment_rounded),
          const SizedBox(height: 12),

          // Cara bayar toggle
          Row(
            children: _caraBayarList.map((item) {
              final isSelected = _selectedCaraBayar == item['code'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCaraBayar = item['code']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: item['code'] == 'BPJ' ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 16,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['name']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedCaraBayar == 'BPJ') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BPJS memerlukan surat rujukan dari Puskesmas atau Dokter Praktek. Akan ditanyakan saat konfirmasi.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          _SectionLabel(label: 'Keluhan', icon: Icons.description_rounded),
          const SizedBox(height: 12),

          TextFormField(
            controller: _keluhanController,
            maxLines: 3,
            decoration: fieldDecor(
              label: 'Keluhan / Alasan (Opsional)',
              icon: Icons.description_rounded,
              hint: 'Contoh: Pusing, Batuk, Kontrol rutin...',
            ).copyWith(
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<JadwalBloc>().add(LoadJadwal()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 15, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _BpjsRujukanDialog extends StatelessWidget {
  const _BpjsRujukanDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF9E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFFF59E0B),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Syarat Layanan BPJS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pendaftaran rawat jalan dengan BPJS di rumah sakit memerlukan:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.local_hospital_rounded,
              text: 'Surat Rujukan dari Puskesmas',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.medical_services_rounded,
              text: 'Atau rujukan dari Dokter Praktek / Klinik',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),
            const Text(
              'Apakah Anda sudah memiliki surat rujukan?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, 'bpjs'),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Ya, Sudah Ada Rujukan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, 'umum'),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Belum — Ganti ke Umum / Mandiri'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context, 'puskesmas'),
                icon: Icon(Icons.directions_walk_rounded, color: Colors.grey[600]),
                label: Text(
                  'Belum — Ke Puskesmas / Dokter Dulu',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
        ),
      ],
    );
  }
}

class _JamRow extends StatelessWidget {
  final String hari;
  final String jam;

  const _JamRow({required this.hari, required this.jam});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(hari, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
        Text(
          jam,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D4ED8),
          ),
        ),
      ],
    );
  }
}
