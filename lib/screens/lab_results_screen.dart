import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/lab/lab_bloc.dart';
import '../blocs/lab/lab_event.dart';
import '../blocs/lab/lab_state.dart';
import '../config/theme.dart';
import '../models/lab_result.dart';
import '../utils/lab_pdf_generator.dart';
import '../widgets/loading_widget.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  bool _hasShownDisclaimer = false;

  @override
  void initState() {
    super.initState();
    // Show disclaimer first, then load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerIfNeeded();
    });
  }

  void _showDisclaimerIfNeeded() {
    if (!_hasShownDisclaimer) {
      _showDisclaimer();
    }
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Informasi Penting',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hasil laboratorium yang ditampilkan adalah untuk informasi dan referensi Anda.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Perhatian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Interpretasi hasil harus dilakukan oleh dokter\n'
                      '• Jangan mengambil keputusan medis sendiri\n'
                      '• Konsultasikan dengan dokter untuk penjelasan lengkap',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dengan melanjutkan, Anda memahami bahwa informasi ini bukan pengganti konsultasi medis profesional.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            child: Text('Kembali', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasShownDisclaimer = true;
              });
              Navigator.pop(context);
              // Load data after disclaimer accepted
              context.read<LabBloc>().add(const FetchLabOrders());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Saya Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Laboratorium')),
      body: BlocBuilder<LabBloc, LabState>(
        builder: (context, state) {
          if (state is LabLoading) {
            return const LoadingWidget(message: 'Memuat data lab...');
          } else if (state is LabOrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada hasil lab',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LabBloc>().add(
                  const FetchLabOrders(isRefresh: true),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _buildLabOrderCard(order);
                },
              ),
            );
          } else if (state is LabResultsLoaded) {
            return _buildLabResultsView(state.results, state.noRawat);
          } else if (state is LabError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LabBloc>().add(const FetchLabOrders());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLabOrderCard(LabOrder order) {
    final date = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(DateTime.parse(order.tglPeriksa));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<LabBloc>().add(FetchLabResults(noRawat: order.noRawat));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.science,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order.jam,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.toLowerCase() == 'selesai'
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: order.status.toLowerCase() == 'selesai'
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.nmDokter,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.local_hospital, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.nmPoli,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf(List<LabResult> results) async {
    final authState = context.read<AuthBloc>().state;
    String nmPasien = '';
    String noRm = '';
    if (authState is AuthAuthenticated) {
      nmPasien = authState.pasien.nmPasien;
      noRm = authState.pasien.noRkmMedis;
    }

    final firstData = results.firstWhere(
      (r) => r.nilai.trim().isNotEmpty,
      orElse: () => results.first,
    );

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membuat PDF...'),
          duration: Duration(seconds: 2),
        ),
      );

      final path = await LabPdfGenerator.generate(
        results: results,
        nmPasien: nmPasien,
        noRm: noRm,
        tglPeriksa: firstData.tglPeriksa,
        nmDokter: firstData.nmDokter,
      );

      if (mounted) {
        await OpenFile.open(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildLabResultsView(List<LabResult> results, String noRawat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<LabBloc>().add(const FetchLabOrders());
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Hasil Lab',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'No. Rawat: $noRawat',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded),
                color: const Color(0xFFDC2626),
                iconSize: 28,
                tooltip: 'Download PDF',
                onPressed: results.isEmpty ? null : () => _downloadPdf(results),
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('Tidak ada hasil lab'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return _buildEnhancedLabResultItem(result);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLabResultItem(LabResult result) {
    final isAbnormal = result.isAbnormal;
    final status = result.status;

    Color statusColor = AppTheme.successColor;
    IconData statusIcon = Icons.check_circle;
    String statusText = 'Normal';

    if (status == 'high') {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.arrow_upward;
      statusText = 'Tinggi';
    } else if (status == 'low') {
      statusColor = Colors.blue;
      statusIcon = Icons.arrow_downward;
      statusText = 'Rendah';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isAbnormal ? 4 : 2,
      color: isAbnormal ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with test name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.nmPerawatan,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Value display with large text
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  result.nilai,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isAbnormal ? statusColor : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    result.satuan,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual progress bar
            if (result.numericValue != null &&
                result.minNormal != null &&
                result.maxNormal != null &&
                result.maxNormal != double.infinity) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rentang Normal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${result.nilaiRujukan} ${result.satuan}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      // Background bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Normal range indicator
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Value indicator
                      FractionallySizedBox(
                        widthFactor: result.progressPercentage,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${result.minNormal}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      Text(
                        '${result.maxNormal}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              // Simple text display for non-numeric or unbounded ranges
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Nilai Normal: ${result.nilaiRujukan} ${result.satuan}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Interpretation message for abnormal values
            if (isAbnormal) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status == 'high'
                            ? 'Nilai di atas batas normal. Konsultasikan dengan dokter.'
                            : 'Nilai di bawah batas normal. Konsultasikan dengan dokter.',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Additional notes/keterangan
            if (result.keterangan != null && result.keterangan!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.keterangan!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
