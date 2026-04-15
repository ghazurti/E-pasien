import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
import 'package:flutter_epasien/widgets/custom_button.dart';
import 'package:flutter_epasien/widgets/custom_textfield.dart';
import 'package:flutter_epasien/widgets/loading_widget.dart';

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
  String _selectedCaraBayar = 'BPJ'; // Default to BPJS

  final List<Map<String, String>> _caraBayarList = [
    {'code': 'BPJ', 'name': 'BPJS'},
    {'code': 'UMU', 'name': 'Umum / Mandiri'},
  ];

  @override
  void initState() {
    super.initState();
    // Trigger load if not already loaded or loading
    final jadwalState = context.read<JadwalBloc>().state;
    if (jadwalState is JadwalInitial) {
      context.read<JadwalBloc>().add(LoadJadwal());
    }
    
    // Note: Pre-selection from jadwal is removed to avoid dropdown errors
    // User will select poli and dokter manually after choosing date
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
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Reset doctor selection when date changes because available doctors may change
        _selectedDokterCode = null;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal periksa terlebih dahulu'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (_selectedPoliCode == null || _selectedDokterCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih Poliklinik dan Dokter terlebih dahulu'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Poli'),
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context); // Kembali setelah sukses
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: BlocBuilder<JadwalBloc, JadwalState>(
          builder: (context, jadwalState) {
            if (jadwalState is JadwalInitial || jadwalState is JadwalLoading) {
              return const LoadingWidget(message: 'Memuat data poliklinik...');
            }
            
            if (jadwalState is JadwalError) {
              return Center(child: Text('Error: ${jadwalState.message}'));
            }

            if (jadwalState is JadwalLoaded) {
              // Extract unique polis
              final List<Jadwal> allJadwal = jadwalState.jadwalList;
              final Map<String, String> poliMap = {};
              for (var j in allJadwal) {
                poliMap[j.kdPoli] = j.nmPoli;
              }
              final List<String> poliCodes = poliMap.keys.toList();

              // Get day name from selected date
              String? selectedDayName;
              if (_selectedDate != null) {
                final dayIndex = _selectedDate!.weekday; // 1=Monday, 7=Sunday
                const dayNames = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'AKHAD'];
                selectedDayName = dayNames[dayIndex - 1];
              }

              // Get doctors for selected poli and date
              List<Jadwal> doctorsInPoli = [];
              if (_selectedPoliCode != null) {
                doctorsInPoli = allJadwal.where((j) {
                  // Filter by poli
                  if (j.kdPoli != _selectedPoliCode) return false;
                  
                  // If date is selected, also filter by day
                  if (selectedDayName != null) {
                    return j.hariKerja.toUpperCase() == selectedDayName;
                  }
                  
                  return true;
                }).toList();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tanggal Periksa
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Periksa',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Pilih tanggal'
                                : DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),


                      // Poliklinik Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPoliCode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Pilih Poliklinik',
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.local_hospital,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        icon: const Icon(Icons.arrow_drop_down_circle, color: AppTheme.primaryColor),
                        dropdownColor: Colors.white,
                        items: poliCodes.map((code) {
                          final poliName = poliMap[code]!;
                          IconData poliIcon = Icons.medical_services;
                          
                          // Assign icons based on poli name
                          if (poliName.toLowerCase().contains('anak')) {
                            poliIcon = Icons.child_care;
                          } else if (poliName.toLowerCase().contains('gigi')) {
                            poliIcon = Icons.medication;
                          } else if (poliName.toLowerCase().contains('mata')) {
                            poliIcon = Icons.visibility;
                          } else if (poliName.toLowerCase().contains('jantung') || poliName.toLowerCase().contains('kardio')) {
                            poliIcon = Icons.favorite;
                          } else if (poliName.toLowerCase().contains('bedah')) {
                            poliIcon = Icons.healing;
                          } else if (poliName.toLowerCase().contains('kulit')) {
                            poliIcon = Icons.face;
                          } else if (poliName.toLowerCase().contains('paru') || poliName.toLowerCase().contains('dalam')) {
                            poliIcon = Icons.air;
                          } else if (poliName.toLowerCase().contains('saraf')) {
                            poliIcon = Icons.psychology;
                          } else if (poliName.toLowerCase().contains('kandungan') || poliName.toLowerCase().contains('obgyn')) {
                            poliIcon = Icons.pregnant_woman;
                          } else if (poliName.toLowerCase().contains('tht')) {
                            poliIcon = Icons.hearing;
                          }
                          
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Row(
                              children: [
                                Icon(poliIcon, size: 20, color: AppTheme.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    poliName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPoliCode = value;
                            _selectedDokterCode = null; // Reset dokter saat poli ganti
                          });
                        },
                        validator: (value) => value == null ? 'Pilih poliklinik' : null,
                      ),
                      const SizedBox(height: 16),

                      // Dokter Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDokterCode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Pilih Dokter',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: _selectedDate == null 
                              ? 'Pilih tanggal terlebih dahulu'
                              : _selectedPoliCode == null 
                                  ? 'Pilih poliklinik terlebih dahulu' 
                                  : doctorsInPoli.isEmpty
                                      ? 'Tidak ada dokter tersedia pada hari ini'
                                      : null,
                        ),
                        items: doctorsInPoli.map((j) {
                          return DropdownMenuItem<String>(
                            value: j.kdDokter,
                            child: Text(j.nmDokter),
                          );
                        }).toList(),
                        onChanged: (_selectedDate == null || _selectedPoliCode == null) 
                          ? null 
                          : (value) {
                              setState(() {
                                _selectedDokterCode = value;
                              });
                            },
                        validator: (value) => value == null ? 'Pilih dokter' : null,
                      ),
                      const SizedBox(height: 16),

                      // Cara Bayar Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCaraBayar,
                        decoration: InputDecoration(
                          labelText: 'Cara Bayar',
                          prefixIcon: const Icon(Icons.payment),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _caraBayarList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['code'],
                            child: Text(item['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCaraBayar = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Keluhan Field
                      CustomTextField(
                        label: 'Keluhan / Alasan (Opsional)',
                        hint: 'Contoh: Pusing, Batuk, Kontrol rutin',
                        controller: _keluhanController,
                        prefixIcon: Icons.description,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      BlocBuilder<BookingBloc, BookingState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: 'Konfirmasi Booking',
                            onPressed: _handleSubmit,
                            isLoading: state is BookingLoading,
                            icon: Icons.check_circle,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Gagal memuat data jadwal.'),
                  const SizedBox(height: 8),
                  Text('State: ${jadwalState.runtimeType}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<JadwalBloc>().add(LoadJadwal()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
