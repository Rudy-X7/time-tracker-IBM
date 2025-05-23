import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import 'storage_helper.dart';

class ProjectProvider extends ChangeNotifier {
  final StorageHelper _storage = StorageHelper();
  List<Project> _projects = [];
  static const String STORAGE_KEY = 'projects';
  final Uuid _uuid = const Uuid();

  List<Project> get projects => [..._projects];

  bool _isLoaded = false;

  /// Load from storage or set defaults if empty
  Future<void> loadProjects() async {
    if (_isLoaded) return;
    try {
      final data = await _storage.getData(STORAGE_KEY);
      if (data != null && data is List && data.isNotEmpty) {
        _projects = data
            .map((item) => Project.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _initializeDefaultProjects();
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading projects: $e');
    }
  }

  void _initializeDefaultProjects() {
    _projects = [
      Project(id: _uuid.v4(), name: 'App Development'),
      Project(id: _uuid.v4(), name: 'Website Redesign'),
      Project(id: _uuid.v4(), name: 'Marketing Campaign'),
    ];
    _saveProjects();
  }

  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> updateProject(Project updatedProject) async {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      await _saveProjects();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> _saveProjects() async {
    try {
      await _storage.saveData(
        STORAGE_KEY,
        _projects.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Error saving projects: $e');
    }
  }

  Project? getProjectById(String id) {
    return _projects.firstWhere((p) => p.id == id, orElse: () => null);
  }
}
