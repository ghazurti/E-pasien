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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Catatan Medis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<RekamMedisBloc, RekamMedisState>(
        builder: (context, state) {
          if (state is RekamMedisLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (state is RekamMedisError) {
            return ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<RekamMedisBloc>().add(LoadRekamMedisHistory());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is RekamMedisLoaded) {
            if (state.history.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 24),
                        Text(
                          'Belum Ada Catatan Medis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Riwayat kunjungan akan muncul di sini',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: () async {
                context.read<RekamMedisBloc>().add(
                  const LoadRekamMedisHistory(isRefresh: true),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  return _RekamMedisCard(
                    record: state.history[index],
                    initiallyExpanded: index == 0,
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

class _RekamMedisCard extends StatefulWidget {
  final RekamMedis record;
  final bool initiallyExpanded;

  const _RekamMedisCard({
    required this.record,
    this.initiallyExpanded = false,
  });

  @override
  State<_RekamMedisCard> createState() => _RekamMedisCardState();
}

class _RekamMedisCardState extends State<_RekamMedisCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .toLowerCase()
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(_expanded ? 0 : 16),
              bottomRight: Radius.circular(_expanded ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _toTitleCase(widget.record.nmPoli),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dateFormat.format(widget.record.tglRegistrasi),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _toTitleCase(widget.record.nmDokter),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // Expanded detail
          if (_expanded) ...[
            Container(height: 1, color: const Color(0xFFEEF2F7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVitals(),
                  const SizedBox(height: 14),
                  _buildSoapBlock(
                    label: 'S',
                    title: 'Subjective — Keluhan',
                    content: widget.record.keluhan,
                    color: const Color(0xFF3B82F6),
                  ),
                  _buildSoapBlock(
                    label: 'O',
                    title: 'Objective — Pemeriksaan',
                    content: widget.record.pemeriksaan,
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildSoapBlock(
                    label: 'A',
                    title: 'Assessment — Diagnosa',
                    content: widget.record.penilaian,
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildSoapBlock(
                    label: 'P',
                    title: 'Plan — Instruksi / RTL',
                    content: widget.record.rtl ?? widget.record.instruksi,
                    color: AppTheme.primaryColor,
                    last: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitals() {
    final vitals = <_VitalData>[
      _VitalData('Tensi', widget.record.tensi, 'mmHg', Icons.favorite_rounded, const Color(0xFFEF4444)),
      _VitalData('Nadi', widget.record.nadi, '/mnt', Icons.monitor_heart_rounded, const Color(0xFF3B82F6)),
      _VitalData('Suhu', widget.record.suhuTubuh, '°C', Icons.thermostat_rounded, const Color(0xFFF59E0B)),
      _VitalData('BB', widget.record.berat, 'kg', Icons.scale_rounded, const Color(0xFF10B981)),
    ];

    final hasAnyVital = vitals.any((v) => v.value != null && v.value!.isNotEmpty);
    if (!hasAnyVital) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanda-Tanda Vital',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: vitals.map((v) => Expanded(child: _VitalChip(data: v))).toList(),
        ),
      ],
    );
  }

  Widget _buildSoapBlock({
    required String label,
    required String title,
    required String? content,
    required Color color,
    bool last = false,
  }) {
    final text = (content != null && content.trim().isNotEmpty)
        ? content.trim()
        : 'Tidak ada catatan';
    final isEmpty = (content == null || content.trim().isEmpty);

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: isEmpty ? Colors.grey[400] : const Color(0xFF334155),
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalData {
  final String label;
  final String? value;
  final String unit;
  final IconData icon;
  final Color color;

  const _VitalData(this.label, this.value, this.unit, this.icon, this.color);
}

class _VitalChip extends StatelessWidget {
  final _VitalData data;

  const _VitalChip({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasValue = data.value != null && data.value!.isNotEmpty;
    final displayVal = hasValue ? data.value! : '-';

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: data.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(data.icon, size: 16, color: data.color),
          const SizedBox(height: 4),
          Text(
            displayVal,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: hasValue ? const Color(0xFF1E293B) : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            data.label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
