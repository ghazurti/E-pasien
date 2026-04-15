import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/kamar/kamar_bloc.dart';
import '../blocs/kamar/kamar_event.dart';
import '../blocs/kamar/kamar_state.dart';
import '../config/theme.dart';
import '../models/kamar.dart';

class KamarScreen extends StatefulWidget {
  const KamarScreen({super.key});

  @override
  State<KamarScreen> createState() => _KamarScreenState();
}

class _KamarScreenState extends State<KamarScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ketersediaan Kamar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<KamarBloc, KamarState>(
              builder: (context, state) {
                if (state is KamarInitial) {
                  context.read<KamarBloc>().add(FetchKetersediaanKamar());
                  return const Center(child: CircularProgressIndicator());
                } else if (state is KamarLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is KamarLoaded) {
                  final filteredKamar = state.kamar.where((k) {
                    final query = _searchQuery.toLowerCase();
                    return k.nmBangsal.toLowerCase().contains(query) ||
                        k.kelas.toLowerCase().contains(query);
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<KamarBloc>().add(
                        FetchKetersediaanKamar(isRefresh: true),
                      );
                    },
                    child: _buildKamarList(filteredKamar, context),
                  );
                } else if (state is KamarError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<KamarBloc>().add(
                              FetchKetersediaanKamar(),
                            );
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari Ruangan atau Kelas...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildKamarList(List<Kamar> kamarList, BuildContext context) {
    if (kamarList.isEmpty) {
      return const Center(child: Text('Tidak ada data kamar tersedia'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kamarList.length,
      itemBuilder: (context, index) {
        final kamar = kamarList[index];
        final bool isFull = kamar.kosong == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Class/Indicator Sidebar
                Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: _getClassColor(kamar.kelas),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                kamar.nmBangsal,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getClassColor(
                                  kamar.kelas,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                kamar.kelas,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getClassColor(kamar.kelas),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoItem(
                              context,
                              'Tersedia',
                              '${kamar.kosong}',
                              isFull ? Colors.red : Colors.green,
                              Icons.meeting_room,
                            ),
                            const SizedBox(width: 24),
                            _buildInfoItem(
                              context,
                              'Terisi',
                              '${kamar.isi}',
                              Colors.blue,
                              Icons.person_pin,
                            ),
                            const SizedBox(width: 24),
                            _buildInfoItem(
                              context,
                              'Total',
                              '${kamar.total}',
                              Colors.grey[700]!,
                              Icons.hotel,
                            ),
                          ],
                        ),
                        if (isFull)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kamar Penuh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getClassColor(String kelas) {
    switch (kelas.toUpperCase()) {
      case 'VIP':
        return const Color(0xFFFFD700); // Gold
      case 'KELAS 1':
        return const Color(0xFF3B82F6); // Blue
      case 'KELAS 2':
        return const Color(0xFF10B981); // Green
      case 'KELAS 3':
        return const Color(0xFFF59E0B); // Orange
      default:
        return Colors.blueGrey;
    }
  }
}
