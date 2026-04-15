import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/radiology/radiology_bloc.dart';
import '../blocs/radiology/radiology_event.dart';
import '../blocs/radiology/radiology_state.dart';
import '../models/radiology_result.dart';
import '../services/radiology_service.dart';
import '../config/theme.dart';

class RadiologyResultsScreen extends StatefulWidget {
  const RadiologyResultsScreen({super.key});

  @override
  State<RadiologyResultsScreen> createState() => _RadiologyResultsScreenState();
}

class _RadiologyResultsScreenState extends State<RadiologyResultsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RadiologyBloc>().add(const LoadRadiologyHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Radiologi'), centerTitle: true),
      body: BlocBuilder<RadiologyBloc, RadiologyState>(
        builder: (context, state) {
          if (state is RadiologyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RadiologyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RadiologyBloc>().add(
                        const LoadRadiologyHistory(isRefresh: true),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is RadiologyLoaded) {
            if (state.history.isEmpty) {
              return const Center(
                child: Text('Belum ada riwayat pemeriksaan radiologi'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RadiologyBloc>().add(
                  const LoadRadiologyHistory(isRefresh: true),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  return _RadiologyOrderCard(order: state.history[index]);
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

class _RadiologyOrderCard extends StatefulWidget {
  final RadiologyOrder order;

  const _RadiologyOrderCard({required this.order});

  @override
  State<_RadiologyOrderCard> createState() => _RadiologyOrderCardState();
}

class _RadiologyOrderCardState extends State<_RadiologyOrderCard> {
  List<RadiologyResult>? _results;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          widget.order.nmPerawatan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(widget.order.tglPeriksa)),
            Text(
              widget.order.nmDokter,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.order.status == 'Sudah'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.order.status,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.order.status == 'Sudah'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
        ),
        onExpansionChanged: (expanded) async {
          if (expanded && _results == null) {
            setState(() => _isLoading = true);

            try {
              final service = RadiologyService();
              final results = await service.getRadiologyDetail(
                widget.order.noRawat,
              );
              setState(() {
                _results = results;
                _isLoading = false;
              });
            } catch (e) {
              setState(() {
                _error = e.toString();
                _isLoading = false;
              });
            }
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : _results == null || _results!.isEmpty
                ? const Text('Hasil belum tersedia')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _results!
                        .map((res) => _buildDetailSection(res))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(RadiologyResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and time
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd MMM yyyy', 'id').format(result.tglPeriksa)} • ${result.jam}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Results content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Hasil Pemeriksaan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    result.hasil,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
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
