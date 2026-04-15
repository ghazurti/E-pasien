import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../blocs/surat_kontrol/surat_kontrol_bloc.dart';
import '../blocs/surat_kontrol/surat_kontrol_event.dart';
import '../blocs/surat_kontrol/surat_kontrol_state.dart';
import '../config/theme.dart';
import '../models/surat_kontrol.dart';

class SuratKontrolScreen extends StatefulWidget {
  const SuratKontrolScreen({super.key});

  @override
  State<SuratKontrolScreen> createState() => _SuratKontrolScreenState();
}

class _SuratKontrolScreenState extends State<SuratKontrolScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SuratKontrolBloc>().add(const FetchSuratKontrol());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surat Kontrol BPJS'),
        centerTitle: true,
      ),
      body: BlocConsumer<SuratKontrolBloc, SuratKontrolState>(
        listener: (context, state) {
          if (state is SuratKontrolDownloaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF berhasil didownload'),
                backgroundColor: Colors.green,
              ),
            );
            // Open the downloaded PDF
            OpenFile.open(state.filePath);
          } else if (state is SuratKontrolError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SuratKontrolLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SuratKontrolError && state is! SuratKontrolDownloaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SuratKontrolBloc>().add(
                        const FetchSuratKontrol(),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is SuratKontrolLoaded) {
            if (state.suratKontrolList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada surat kontrol',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SuratKontrolBloc>().add(
                  const FetchSuratKontrol(isRefresh: true),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.suratKontrolList.length,
                itemBuilder: (context, index) {
                  return _SuratKontrolCard(
                    suratKontrol: state.suratKontrolList[index],
                  );
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

class _SuratKontrolCard extends StatelessWidget {
  final SuratKontrol suratKontrol;

  const _SuratKontrolCard({required this.suratKontrol});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_ind,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suratKontrol.noSurat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tgl Surat: ${dateFormat.format(suratKontrol.tglSurat)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Rencana Kontrol',
              dateFormat.format(suratKontrol.tglRencana),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.local_hospital,
              'Poliklinik',
              suratKontrol.nmPoliBpjs,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, 'Dokter', suratKontrol.nmDokterBpjs),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<SuratKontrolBloc>().add(
                    DownloadSuratKontrol(suratKontrol.noSurat),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
