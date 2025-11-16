import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jobreport/models/task.dart';
import 'package:jobreport/models/period.dart';
import 'package:jobreport/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jobreport/widgets/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _databaseService = DatabaseService();
  List<Task> _tasks = [];
  List<Period> _filteredPeriods = [];
  final Set<String> _typeFilters = {};
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _databaseService.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _filterPeriods();
      });
    }
  }

  void _filterPeriods() {
    setState(() {
      final allPeriods = _tasks.expand((task) => task.periods).toList();
      if (_typeFilters.isEmpty) {
        _filteredPeriods = allPeriods;
      } else {
        _filteredPeriods = allPeriods.where((period) => _typeFilters.contains(period.type)).toList();
      }
    });
  }

  String _jsonString() {
    return const JsonEncoder.withIndent('  ').convert(_tasks.map((t) => t.toJson()).toList());
  }

  Future<void> _exportToJson() async {
    final uri = Uri.dataFromString(
      _jsonString(),
      mimeType: 'application/json',
      encoding: utf8,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not export JSON.');
    }
  }

  Future<void> _sendEmail() async {
    final subject = 'Job Report - ${DateFormat.yMd().format(DateTime.now())}';
    final body = 'Please find the attached job report data.\n\n${_jsonString()}';
    final uri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not open email client.');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    duration = duration.isNegative ? Duration.zero : duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, Duration> _getPeriodDurations() {
    final durations = {'active': Duration.zero, 'idle': Duration.zero, 'on-meeting': Duration.zero};
    for (var task in _tasks) {
      for (var period in task.periods) {
        if(period.end != null){
          final duration = period.getDuration(null);
          durations[period.type] = (durations[period.type] ?? Duration.zero) + duration;
        }
      }
    }
    return durations;
  }

  @override
  Widget build(BuildContext context) {
    final periodDurations = _getPeriodDurations();
    final totalTime = periodDurations.values.fold(Duration.zero, (prev, element) => prev + element);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: _sendEmail,
            tooltip: 'Send Email',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportToJson,
            tooltip: 'Export JSON',
          ),
        ],
      ),
      drawer: const AppSidebar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Distribution', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: periodDurations.entries.map((entry) {
                              final isTouched = periodDurations.keys.toList().indexOf(entry.key) == _touchedIndex;
                              final percentage = totalTime.inSeconds == 0 ? 0 : (entry.value.inSeconds / totalTime.inSeconds) * 100;
                              return PieChartSectionData(
                                color: _getTypeColor(entry.key),
                                value: entry.value.inSeconds.toDouble(),
                                title: '${percentage.toStringAsFixed(1)}%',
                                radius: isTouched ? 60.0 : 50.0,
                                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: periodDurations.entries.map((entry) {
                          return _buildIndicator(color: _getTypeColor(entry.key), text: '${entry.key.capitalize()} (${_formatDuration(entry.value)})');
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Detailed Log', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: ['active', 'idle', 'on-meeting'].map((type) {
                return FilterChip(
                  label: Text(type.capitalize()),
                  selected: _typeFilters.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _typeFilters.add(type);
                      } else {
                        _typeFilters.remove(type);
                      }
                      _filterPeriods();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Task')),
                      DataColumn(label: Text('Period Type')),
                      DataColumn(label: Text('Start Time')),
                      DataColumn(label: Text('End Time')),
                      DataColumn(label: Text('Duration')),
                      DataColumn(label: Text('Description')),
                    ],
                    rows: _filteredPeriods.map((period) {
                      final task = _tasks.firstWhere((t) => t.periods.contains(period), orElse: () => _tasks.first);
                      return DataRow(
                        cells: [
                          DataCell(Text(task.description)),
                          DataCell(Chip(label: Text(period.type.capitalize()), backgroundColor: _getTypeColor(period.type))),
                          DataCell(Text(DateFormat.jm().format(period.start))),
                          DataCell(Text(period.end != null ? DateFormat.jm().format(period.end!) : 'Now')),
                          DataCell(Text(_formatDuration(period.getDuration(null)))),
                          DataCell(Text(period.description)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4), color: color)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'active':
        return Colors.green.shade400;
      case 'idle':
        return Colors.orange.shade400;
      case 'on-meeting':
        return Colors.purple.shade400;
      default:
        return Colors.grey;
    }
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
