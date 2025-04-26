import 'package:flutter/foundation.dart';
import '../models/project.dart';
import 'storage_helper.dart';

class ProjectProvider extends ChangeNotifier {
  final StorageHelper _storage = StorageHelper();
  List<Project> _projects = [];
  static const String STORAGE_KEY = 'projects';

  List<Project> get projects => [..._projects];

  Future<void> loadProjects() async {
    try {
      final data = await _storage.getData(STORAGE_KEY);
      if (data != null && data is List) {
        _projects =
            data
                .map((item) => Project.fromJson(item as Map<String, dynamic>))
                .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading projects: $e');
    }
  }

  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> updateProject(Project updatedProject) async {
    final projectIndex = _projects.indexWhere(
      (project) => project.id == updatedProject.id,
    );
    if (projectIndex >= 0) {
      _projects[projectIndex] = updatedProject;
      await _saveProjects();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((project) => project.id == projectId);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> _saveProjects() async {
    try {
      await _storage.saveData(
        STORAGE_KEY,
        _projects.map((project) => project.toJson()).toList(),
      );
    } catch (e) {
      print('Error saving projects: $e');
    }
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
}
