import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobreport/models/daily_report.dart';
import 'package:jobreport/screens/login_screen.dart';
import 'package:jobreport/services/auth_service.dart';
import 'package:jobreport/widgets/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyReportScreen extends StatefulWidget {
  final DailyReport report;

  const DailyReportScreen({super.key, required this.report});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _sendEmail(BuildContext context) async {
    final subject = 'Daily Report - ${DateFormat.yMd().format(widget.report.date)}';
    final body = _generateReportBody();
    final uri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client.'), backgroundColor: Colors.red),
      );
    }
  }

  String _generateReportBody() {
    final standardWorkDay = const Duration(hours: 8);
    final overtime = widget.report.totalWorkTime - standardWorkDay;
    final jsonReport = const JsonEncoder.withIndent('  ').convert(widget.report.toJson());

    return '''
      Daily Report - ${DateFormat.yMMMEd().format(widget.report.date)}

      Login Time: ${DateFormat.jm().format(widget.report.loginTime)}
      Logout Time: ${DateFormat.jm().format(widget.report.logoutTime)}

      Total Work Time: ${_formatDuration(widget.report.totalWorkTime)}
      Idle Time: ${_formatDuration(widget.report.idleTime)}

      Standard Work Day: ${_formatDuration(standardWorkDay)}
      Overtime/Undertime: ${_formatDuration(overtime, showSign: true)}

      Total Tasks Assigned: ${widget.report.totalTasksAssigned}
      Total Tasks Completed: ${widget.report.totalTasksCompleted}
      Total Pending Tasks: ${widget.report.totalPendingTasks}
      Total Active Sessions: ${widget.report.totalActiveSessions}

      ---------------------
      JSON REPORT
      ---------------------
      $jsonReport
    ''';
  }

  Future<void> _finalizeLogout() async {
    await AuthService().logout();
    if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardWorkDay = const Duration(hours: 8);
    final overtime = widget.report.totalWorkTime - standardWorkDay;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text('Daily Report - ${DateFormat.yMd().format(widget.report.date)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: () => _sendEmail(context),
            tooltip: 'Send Email',
          ),
          TextButton.icon(
            onPressed: _finalizeLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Finalize Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: const AppSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Metric')),
              DataColumn(label: Text('Value')),
            ],
            rows: [
              DataRow(cells: [const DataCell(Text('Date')), DataCell(Text(DateFormat.yMMMEd().format(widget.report.date)))]),
              DataRow(cells: [const DataCell(Text('Login Time')), DataCell(Text(DateFormat.jm().format(widget.report.loginTime)))]),
              DataRow(cells: [const DataCell(Text('Logout Time')), DataCell(Text(DateFormat.jm().format(widget.report.logoutTime)))]),
              DataRow(cells: [const DataCell(Text('Total Work Time')), DataCell(Text(_formatDuration(widget.report.totalWorkTime)))]),
              DataRow(cells: [const DataCell(Text('Idle Time')), DataCell(Text(_formatDuration(widget.report.idleTime)))]),
              DataRow(cells: [const DataCell(Text('Standard Work Day')), DataCell(Text(_formatDuration(standardWorkDay)))]),
              DataRow(cells: [const DataCell(Text('Overtime/Undertime')), DataCell(Text(_formatDuration(overtime, showSign: true)))]),
              DataRow(cells: [const DataCell(Text('Total Tasks Assigned')), DataCell(Text(widget.report.totalTasksAssigned.toString()))]),
              DataRow(cells: [const DataCell(Text('Total Tasks Completed')), DataCell(Text(widget.report.totalTasksCompleted.toString()))]),
              DataRow(cells: [const DataCell(Text('Total Pending Tasks')), DataCell(Text(widget.report.totalPendingTasks.toString()))]),
              DataRow(cells: [const DataCell(Text('Total Active Sessions')), DataCell(Text(widget.report.totalActiveSessions.toString()))]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration, {bool showSign = false}) {
    final sign = duration.isNegative ? '-' : (showSign ? '+' : '');
    duration = duration.abs();
    return '$sign${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }
}
