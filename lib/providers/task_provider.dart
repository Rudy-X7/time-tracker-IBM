import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'storage_helper.dart';

class TaskProvider extends ChangeNotifier {
  final StorageHelper _storage = StorageHelper();
  List<Task> _tasks = [];
  static const String STORAGE_KEY = 'tasks';

  List<Task> get tasks => [..._tasks];

  Future<void> loadTasks() async {
    try {
      final data = await _storage.getData(STORAGE_KEY);
      if (data != null && data is List) {
        _tasks =
            data
                .map((item) => Task.fromJson(item as Map<String, dynamic>))
                .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex >= 0) {
      _tasks[taskIndex] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    try {
      await _storage.saveData(
        STORAGE_KEY,
        _tasks.map((task) => task.toJson()).toList(),
      );
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksByProjectId(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    _tasks.removeWhere((task) => task.projectId == projectId);
    await _saveTasks();
    notifyListeners();
  }
}
