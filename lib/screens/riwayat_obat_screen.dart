import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/riwayat_obat.dart';
import '../services/riwayat_obat_service.dart';

class RiwayatObatScreen extends StatefulWidget {
  const RiwayatObatScreen({super.key});

  @override
  State<RiwayatObatScreen> createState() => _RiwayatObatScreenState();
}

class _RiwayatObatScreenState extends State<RiwayatObatScreen> {
  final RiwayatObatService _service = RiwayatObatService();
  List<Resep> _resepList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getRiwayatObat();
      if (mounted) {
        setState(() {
          _resepList = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Riwayat Obat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_error != null) {
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
                  onPressed: _loadData,
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

    if (_resepList.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 24),
                Text(
                  'Belum Ada Riwayat Obat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Riwayat resep dokter akan muncul di sini',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _resepList.length,
      itemBuilder: (context, index) {
        return _ResepCard(
          resep: _resepList[index],
          initiallyExpanded: index == 0,
        );
      },
    );
  }
}

class _ResepCard extends StatelessWidget {
  final Resep resep;
  final bool initiallyExpanded;

  const _ResepCard({required this.resep, this.initiallyExpanded = false});

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF009B3A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Color(0xFF009B3A),
                size: 22,
              ),
            ),
            title: Text(
              _formatDate(resep.tglPeresepan),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  resep.nmDokter,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009B3A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${resep.obat.length} jenis obat',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF009B3A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
            children: [
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: resep.obat.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _ObatTile(obat: resep.obat[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObatTile extends StatelessWidget {
  final ObatItem obat;

  const _ObatTile({required this.obat});

  @override
  Widget build(BuildContext context) {
    final jmlStr = obat.jml == obat.jml.truncateToDouble()
        ? obat.jml.toInt().toString()
        : obat.jml.toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: Color(0xFF009B3A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obat.namaObat.isEmpty ? '-' : obat.namaObat,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.numbers_rounded,
                      label: '$jmlStr pcs',
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 8),
                    if (obat.aturanPakai.isNotEmpty)
                      _Chip(
                        icon: Icons.schedule_rounded,
                        label: obat.aturanPakai,
                        color: const Color(0xFFF59E0B),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
