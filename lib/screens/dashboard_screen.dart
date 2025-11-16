import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobreport/models/daily_report.dart';
import 'package:jobreport/models/period.dart';
import 'package:jobreport/models/task.dart';
import 'package:jobreport/screens/daily_report_screen.dart';
import 'package:jobreport/services/auth_service.dart';
import 'package:jobreport/services/database_service.dart';
import 'package:jobreport/services/timer_service.dart';
import 'package:jobreport/widgets/sidebar.dart';
import 'package:jobreport/widgets/task_dialog.dart';
import 'package:uuid/uuid.dart';

import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final dbService = DatabaseService();
  final timerService = TimerService();
  final authService = AuthService();
  final uuid = const Uuid();

  List<Task> tasks = [];
  DateTime workdayStart = DateTime.now();
  Timer? _hourlyPromptTimer;
  bool _inMeeting = false;

  @override
  void initState() {
    super.initState();
    html.window.onBeforeUnload.listen((event) async {
      await _saveStateOnExit(DateTime.now());
    });
    _loadData();
    timerService.start(_handleTick);
    _startHourlyPrompts();
  }

  @override
  void dispose() {
    timerService.stop();
    _hourlyPromptTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveStateOnExit(DateTime exitTime) async {
    if (tasks.isNotEmpty) {
      final activeTaskIndex = tasks.indexWhere((t) => t.status == 'Active');
      if (activeTaskIndex != -1) {
        final activeTask = tasks[activeTaskIndex];
        final lastPeriod = activeTask.periods.last;

        if (lastPeriod.end == null) {
            final updatedPeriods = List<Period>.from(activeTask.periods);
            updatedPeriods[updatedPeriods.length - 1] = lastPeriod.copyWith(end: exitTime);

            final updatedTask = Task(
                taskId: activeTask.taskId,
                createdAt: activeTask.createdAt,
                description: activeTask.description,
                status: activeTask.status,
                periods: updatedPeriods,
            );
            await dbService.updateTask(updatedTask);
        }
      }
    }
  }

  void _handleTick(bool wokeFromSleep) {
    if (!mounted) return;
    if (wokeFromSleep) {
      _handleWakeUp();
    }
    setState(() {});
  }

  void _startHourlyPrompts() {
    _hourlyPromptTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _promptForHourlyDescription();
    });
  }

  Future<void> _promptForHourlyDescription() async {
    final activeTaskIndex = tasks.indexWhere((t) => t.status == 'Active');
    if (activeTaskIndex == -1 || !context.mounted) return;

    final task = tasks[activeTaskIndex];
    final now = DateTime.now();
    final lastPeriod = task.periods.last;

    final newPeriod = Period(
      periodId: uuid.v4(),
      start: now,
      type: 'active',
      description: await TaskDialog.show(context, 'Hourly Description') ?? '',
    );

    final updatedPeriods = List<Period>.from(task.periods);
    updatedPeriods[updatedPeriods.length - 1] = lastPeriod.copyWith(end: now);
    updatedPeriods.add(newPeriod);

    final updatedTask = Task(
      taskId: task.taskId,
      createdAt: task.createdAt,
      description: task.description,
      status: task.status,
      periods: updatedPeriods,
    );

    await dbService.updateTask(updatedTask);
    setState(() {
      tasks[activeTaskIndex] = updatedTask;
    });
  }

  Future<void> _loadData() async {
    tasks = await dbService.getTasks();
    if (tasks.isEmpty) {
      final t = _makeNewTask(description: 'Workday Start');
      tasks.add(t);
      await dbService.saveTasks(tasks);
    } else {
      workdayStart = _inferWorkdayStart() ?? DateTime.now();
      await _handleAppReopen();
    }
    if (mounted) {
        setState(() {});
    }
  }

  Future<void> _handleAppReopen() async {
    if (tasks.isEmpty) return;
    final activeTaskIndex = tasks.indexWhere((t) => t.status == 'Active');
    if (activeTaskIndex == -1) return;

    final activeTask = tasks[activeTaskIndex];
    final lastPeriod = activeTask.periods.last;
    final now = DateTime.now();

    if (lastPeriod.end != null && now.difference(lastPeriod.end!) > const Duration(minutes: 1)) {
      final description = await TaskDialog.show(context, 'Welcome back! What were you working on?') ?? 'Offline work';

      final idlePeriod = Period(
        periodId: uuid.v4(),
        start: lastPeriod.end!,
        end: now,
        type: 'idle',
        description: description,
      );

      final newActivePeriod = Period(
        periodId: uuid.v4(),
        start: now,
        type: 'active',
        description: 'Resumed after offline period',
      );

      final updatedPeriods = List<Period>.from(activeTask.periods)..add(idlePeriod)..add(newActivePeriod);

      final updatedTask = Task(
        taskId: activeTask.taskId,
        createdAt: activeTask.createdAt,
        description: activeTask.description,
        status: activeTask.status,
        periods: updatedPeriods,
      );

      await dbService.updateTask(updatedTask);
      setState(() {
        tasks[activeTaskIndex] = updatedTask;
      });
    }
  }

  DateTime? _inferWorkdayStart() {
    if (tasks.isEmpty) return DateTime.now();
    DateTime? earliest;
    for (var t in tasks) {
      final c = t.createdAt;
      if (DateTime.now().difference(c).inDays == 0) {
        earliest = (earliest == null || c.isBefore(earliest)) ? c : earliest;
      }
    }
    return earliest;
  }

  Task _makeNewTask({required String description}) {
    final id = uuid.v4();
    final now = DateTime.now();
    return Task(
      taskId: id,
      createdAt: now,
      description: description,
      status: 'Active',
      periods: [Period(periodId: uuid.v4(), start: now, type: 'active', description: description)],
    );
  }

  Future<void> _createTask() async {
    final desc = await TaskDialog.show(context, 'New Task');
    if (desc == null || desc.trim().isEmpty) return;
    tasks.add(_makeNewTask(description: desc.trim()));
    await dbService.saveTasks(tasks);
    setState(() {});
  }

  Future<void> _markComplete(Task task) async {
    final now = DateTime.now();
    final updatedPeriods = List<Period>.from(task.periods);
    final lastPeriod = task.periods.isNotEmpty ? task.periods.last : null;
    if (lastPeriod != null && lastPeriod.end == null) {
      updatedPeriods[updatedPeriods.length - 1] = lastPeriod.copyWith(end: now);
    }

    final updatedTask = Task(
      taskId: task.taskId,
      createdAt: task.createdAt,
      description: task.description,
      status: 'Completed',
      periods: updatedPeriods,
    );

    final taskIndex = tasks.indexOf(task);
    await dbService.updateTask(updatedTask);
    setState(() {
      tasks[taskIndex] = updatedTask;
    });
  }

  void _handleWakeUp() async {
    final now = DateTime.now();
    final description = await TaskDialog.show(context, 'Welcome back! You were idle.') ?? 'Idle time';
    final activeTaskIndex = tasks.indexWhere((t) => t.status == 'Active');
    if (activeTaskIndex == -1) return;

    final task = tasks[activeTaskIndex];
    final lastPeriod = task.periods.last;
    final endedLastPeriod = lastPeriod.copyWith(end: timerService.lastActivityTime);

    final idlePeriod = Period(
      periodId: uuid.v4(),
      start: timerService.lastActivityTime,
      end: now,
      type: 'idle',
      description: description,
    );

    final newActivePeriod = Period(
      periodId: uuid.v4(),
      start: now,
      type: 'active',
      description: 'Resumed after idle',
    );

    final updatedPeriods = List<Period>.from(task.periods)
      ..[task.periods.length - 1] = endedLastPeriod
      ..add(idlePeriod)
      ..add(newActivePeriod);

    final updatedTask = Task(
      taskId: task.taskId,
      createdAt: task.createdAt,
      description: task.description,
      status: task.status,
      periods: updatedPeriods,
    );

    await dbService.updateTask(updatedTask);
    setState(() {
      tasks[activeTaskIndex] = updatedTask;
    });
  }

  Future<void> _toggleMeetingMode() async {
    final activeTaskIndex = tasks.indexWhere((t) => t.status == 'Active');
    if (activeTaskIndex == -1) return;

    setState(() => _inMeeting = !_inMeeting);

    final task = tasks[activeTaskIndex];
    final now = DateTime.now();
    final lastPeriod = task.periods.last;

    final newPeriod = Period(
      periodId: uuid.v4(),
      start: now,
      type: _inMeeting ? 'on-meeting' : 'active',
      description: _inMeeting ? 'Meeting started' : 'Meeting ended',
    );

    final updatedPeriods = List<Period>.from(task.periods)
      ..[task.periods.length - 1] = lastPeriod.copyWith(end: now)
      ..add(newPeriod);

    final updatedTask = Task(
      taskId: task.taskId,
      createdAt: task.createdAt,
      description: task.description,
      status: task.status,
      periods: updatedPeriods,
    );

    await dbService.updateTask(updatedTask);
    setState(() {
      tasks[activeTaskIndex] = updatedTask;
    });
  }

  Future<void> _logout() async {
    final logoutTime = timerService.lastActivityTime;
    await _saveStateOnExit(logoutTime);

    final currentTasks = await dbService.getTasks();
    final loginTime = await authService.getLoginTime();

    Duration totalWorkTime = Duration.zero;
    Duration idleTime = Duration.zero;
    int totalActiveSessions = 0;

    for (var task in currentTasks) {
      for (var period in task.periods) {
        if (period.end == null) continue;
        final duration = period.end!.difference(period.start);
        if (period.type == 'active' || period.type == 'on-meeting') {
          totalWorkTime += duration;
          totalActiveSessions++;
        } else if (period.type == 'idle') {
          idleTime += duration;
        }
      }
    }

    final report = DailyReport(
      date: logoutTime,
      loginTime: loginTime ?? logoutTime,
      logoutTime: logoutTime,
      totalWorkTime: totalWorkTime,
      idleTime: idleTime,
      totalTasksAssigned: currentTasks.length,
      totalTasksCompleted: currentTasks.where((t) => t.status == 'Completed').length,
      totalPendingTasks: currentTasks.where((t) => t.status != 'Completed').length,
      totalActiveSessions: totalActiveSessions,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DailyReportScreen(report: report),
        ),
      );
    }
  }

  String _formatDuration(Duration d, {bool showSign = false}) {
    final sign = d.isNegative ? '-' : (showSign ? '+' : '');
    d = d.abs();
    return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: Icon(_inMeeting ? Icons.meeting_room : Icons.meeting_room_outlined),
              onPressed: _toggleMeetingMode,
              tooltip: _inMeeting ? 'End Meeting' : 'Start Meeting',
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ]),
      drawer: const AppSidebar(),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _createTask,
          label: const Text('New Task'),
          icon: const Icon(Icons.add)),
      body: Listener(
        onPointerDown: (_) => timerService.recordActivity(),
        onPointerMove: (_) => timerService.recordActivity(),
        onPointerUp: (_) => timerService.recordActivity(),
        child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkdaySummaryCard(primaryColor, accentColor),
                    const SizedBox(height: 24),
                    Text('Today\'s Tasks', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (tasks.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No tasks yet. Tap + to create one!')))
                    else
                      ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) => _buildTaskCard(tasks[i])),
                  ]),
            )),
      ),
    );
  }

  Card _buildWorkdaySummaryCard(Color primaryColor, Color accentColor) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workday Started: ${_formatDateTime(workdayStart)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    const Text('Total Worked Hours', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(_formatDuration(_getWorkedDuration()), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ))));
  }

  Widget _buildTaskCard(Task t) {
    final now = DateTime.now();
    final activeTime = t.getWorkedDuration(now);

    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
            leading: _buildStatusIndicator(t.status),
            title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Active Time: ${_formatDuration(activeTime)}'),
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: t.periods.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (ctx, i) {
                        final p = t.periods[i];
                        final endText = p.end != null ? DateFormat('HH:mm:ss').format(p.end!) : 'Now';
                        final dur = p.getDuration(now);
                        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${p.type.toUpperCase()}: ${p.description}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('${DateFormat('HH:mm:ss').format(p.start)} → $endText', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ]),
                          Text(_formatDuration(dur), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ]);
                      })),
              ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [if (t.status == 'Active') TextButton(onPressed: () => _markComplete(t), child: const Text('Mark as Completed'))])
            ]));
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;
    if (status == 'Completed') {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (_inMeeting) {
      color = Colors.purple;
      icon = Icons.meeting_room;
    } else {
      color = Colors.blue;
      icon = Icons.run_circle_outlined;
    }
    return Icon(icon, color: color, size: 40);
  }

  Duration _getWorkedDuration() {
    final now = DateTime.now();
    Duration totalWorked = Duration.zero;
    for (var t in tasks) {
      totalWorked += t.getWorkedDuration(now);
    }
    return totalWorked;
  }
}
