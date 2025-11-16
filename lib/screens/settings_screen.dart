import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobreport/services/database_service.dart';
import 'package:jobreport/widgets/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _dbService = DatabaseService();
  bool _isDarkMode = false;
  bool _hourlyReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text('Settings'),
      ),
      drawer: const AppSidebar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildCard([
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Reduce glare and improve night viewing'),
              secondary: const Icon(Icons.brightness_4_outlined),
              value: _isDarkMode,
              onChanged: (value) => setState(() {
                _isDarkMode = value;
                _showComingSoon(context, 'Theme switching');
              }),
            ),
          ]),
          const SizedBox(height: 24),
           _buildSectionHeader(context, 'Notifications'),
          _buildCard([
            SwitchListTile(
              title: const Text('Hourly Reminders'),
              subtitle: const Text('Prompt for a description every hour'),
              secondary: const Icon(Icons.timer_outlined),
              value: _hourlyReminders,
              onChanged: (value) => setState(() {
                _hourlyReminders = value;
                 _showComingSoon(context, 'Notification controls');
              }),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Data Management'),
          _buildCard([
             _buildSettingsTile(
              icon: Icons.download_outlined,
              title: 'Export All Data',
              subtitle: 'Save all your tasks to a JSON file',
              onTap: _exportData,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'Clear All Data',
              subtitle: 'Permanently delete all tasks and reports',
              onTap: _confirmClearData,
              isDestructive: true,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _buildCard([
             _buildSettingsTile(
              icon: Icons.policy_outlined,
              title: 'Privacy Policy',
              onTap: () => _launchUrl('https://example.com/privacy'),
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _launchUrl('https://example.com/terms'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Padding _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Card _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  ListTile _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _exportData() async {
    final tasks = await _dbService.getTasks();
    final json = const JsonEncoder.withIndent('  ').convert(tasks.map((t) => t.toJson()).toList());
    final uri = Uri.dataFromString(json, mimeType: 'application/json', encoding: utf8);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not export data.');
    }
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will permanently delete all your data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbService.clearAll();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been cleared.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not open link.');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }
}
