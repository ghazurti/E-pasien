import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/antrian.dart';
import '../services/antrian_service.dart';

class AntrianScreen extends StatefulWidget {
  const AntrianScreen({super.key});

  @override
  State<AntrianScreen> createState() => _AntrianScreenState();
}

class _AntrianScreenState extends State<AntrianScreen> {
  final AntrianService _service = AntrianService();

  AntrianStatus? _antrian;
  bool _loading = true;
  String? _error;
  int _countdown = 30;
  bool _refreshing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAntrian();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        _countdown = 30;
        _silentRefresh();
      }
    });
  }

  Future<void> _silentRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final antrian = await _service.getAntrianStatus();
      if (mounted) {
        setState(() {
          _antrian = antrian;
          _error = null;
          _countdown = 30;
        });
      }
    } catch (_) {
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _loadAntrian() async {
    setState(() => _loading = true);
    try {
      final antrian = await _service.getAntrianStatus();
      if (mounted) {
        setState(() {
          _antrian = antrian;
          _loading = false;
          _error = null;
          _countdown = 30;
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
          'Status Antrian',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  'Refresh ${_countdown}s',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: _silentRefresh,
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
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadAntrian,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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

    if (_antrian == null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                Text(
                  'Tidak Ada Antrian',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda tidak memiliki antrian\npendaftaran hari ini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Tarik ke bawah untuk memperbarui',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTicket(),
        const SizedBox(height: 16),
        _buildStatusCards(),
        const SizedBox(height: 16),
        _buildEstimationCard(),
        const SizedBox(height: 24),
        _buildRefreshButton(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTicket() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007A2E), Color(0xFF00C94A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009B3A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: Column(
              children: [
                const Text(
                  'NOMOR ANTRIAN ANDA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _antrian!.noAntrian ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 88,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _antrian!.nmPoli,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                28,
                (_) => Expanded(
                  child: Container(
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TicketInfo(
                  label: 'Dokter',
                  value: _antrian!.nmDokter.isNotEmpty
                      ? _antrian!.nmDokter
                      : _antrian!.kdDokter ?? '-',
                ),
                _TicketInfo(
                  label: 'Jam Daftar',
                  value: _formatTime(_antrian!.jamReg),
                  alignment: CrossAxisAlignment.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    final didepan = _antrian!.antrianDidepan;
    final total = _antrian!.totalPasien;

    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            label: 'Sebelum Anda',
            value: '$didepan orang',
            icon: Icons.people_rounded,
            color: didepan == 0
                ? const Color(0xFF009B3A)
                : const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            label: 'Total Terdaftar',
            value: '$total pasien',
            icon: Icons.assignment_ind_rounded,
            color: const Color(0xFF0EA5E9),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimationCard() {
    final estimasi = _antrian!.estimasiMenit;
    final isNext = _antrian!.antrianDidepan == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF6366F1),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimasi Waktu Tunggu',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isNext ? 'Anda giliran berikutnya!' : '± $estimasi menit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isNext
                        ? const Color(0xFF009B3A)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadAntrian,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Perbarui Sekarang'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: const BorderSide(color: AppTheme.primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';
    return time.length >= 5 ? time.substring(0, 5) : time;
  }
}

class _TicketInfo extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  const _TicketInfo({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
