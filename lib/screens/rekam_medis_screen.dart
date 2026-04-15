import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/rekam_medis/rekam_medis_bloc.dart';
import '../blocs/rekam_medis/rekam_medis_event.dart';
import '../blocs/rekam_medis/rekam_medis_state.dart';
import '../models/rekam_medis.dart';
import '../config/theme.dart';

class RekamMedisScreen extends StatefulWidget {
  const RekamMedisScreen({super.key});

  @override
  State<RekamMedisScreen> createState() => _RekamMedisScreenState();
}

class _RekamMedisScreenState extends State<RekamMedisScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RekamMedisBloc>().add(LoadRekamMedisHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Catatan Medis'),
        centerTitle: true,
      ),
      body: BlocBuilder<RekamMedisBloc, RekamMedisState>(
        builder: (context, state) {
          if (state is RekamMedisLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RekamMedisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RekamMedisBloc>().add(
                        LoadRekamMedisHistory(),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is RekamMedisLoaded) {
            if (state.history.isEmpty) {
              return const Center(
                child: Text('Belum ada riwayat catatan medis'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RekamMedisBloc>().add(
                  const LoadRekamMedisHistory(isRefresh: true),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  return _RekamMedisCard(record: state.history[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RekamMedisCard extends StatelessWidget {
  final RekamMedis record;

  const _RekamMedisCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          record.nmPoli,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(record.tglRegistrasi)),
            Text(record.nmDokter, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.medical_services,
            color: AppTheme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildVitalSigns(),
                const SizedBox(height: 16),
                _buildSoapSection('S (Subjective - Keluhan)', record.keluhan),
                _buildSoapSection(
                  'O (Objective - Pemeriksaan)',
                  record.pemeriksaan,
                ),
                _buildSoapSection(
                  'A (Assessment - Diagnosa)',
                  record.penilaian,
                ),
                _buildSoapSection(
                  'P (Plan - Instruksi/RTL)',
                  record.rtl ?? record.instruksi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSigns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanda-Tanda Vital:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _vitalsItem('Tensi', record.tensi ?? '-'),
            _vitalsItem('Nadi', '${record.nadi ?? '-'} /mnt'),
            _vitalsItem('Suhu', '${record.suhuTubuh ?? '-'} °C'),
            _vitalsItem('BB', '${record.berat ?? '-'} kg'),
          ],
        ),
      ],
    );
  }

  Widget _vitalsItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSoapSection(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content ?? 'Tidak ada catatan',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
