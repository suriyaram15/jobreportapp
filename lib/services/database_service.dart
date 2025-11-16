import 'dart:convert';

import 'package:jobreport/models/task.dart';
import 'package:jobreport/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static const String _usersKey = 'users';
  static const String _tasksKey = 'tasks';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers();
    users.add({'id': user.id, 'username': user.username, 'password': user.password});
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<User?> getUser(String username) async {
    final users = await _getUsers();
    try {
      final userMap = users.firstWhere((user) => user['username'] == username);
      return User(id: userMap['id'], username: userMap['username'], password: userMap['password']);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);
    if (usersString != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(usersString));
    }
    return [];
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_tasksKey, jsonData);
  }

  Future<void> updateTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.taskId == task.taskId);
    if (index != -1) {
      tasks[index] = task;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.taskId == taskId);
    await saveTasks(tasks);
  }

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_tasksKey);
    if (data == null || data.isEmpty) return [];
    try {
      final decoded = jsonDecode(data) as List;
      return decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Corrupted data — clear and return empty
      await prefs.remove(_tasksKey);
      return [];
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
