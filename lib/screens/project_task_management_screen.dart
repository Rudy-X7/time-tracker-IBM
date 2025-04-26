import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskManagementScreen extends StatefulWidget {
  const ProjectTaskManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProjectTaskManagementScreen> createState() =>
      _ProjectTaskManagementScreenState();
}

class _ProjectTaskManagementScreenState
    extends State<ProjectTaskManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects & Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Projects', icon: Icon(Icons.folder)),
            Tab(text: 'Tasks', icon: Icon(Icons.task)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ProjectsTab(), TasksTab()],
      ),
    );
  }
}

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({Key? key}) : super(key: key);

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addProject() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Project'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Project Color:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                              Navigator.pop(context);
                              _addProject();
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: color,
                              child:
                                  _selectedColor == color
                                      ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final projectProvider = Provider.of<ProjectProvider>(
                      context,
                      listen: false,
                    );

                    final newProject = Project(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text.trim(),
                      color: _selectedColor.value.toRadixString(16),
                    );

                    projectProvider.addProject(newProject);

                    _nameController.clear();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project added successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _editProject(Project project) {
    _nameController.text = project.name;
    _selectedColor = Color(int.parse(project.color, radix: 16));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Project'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Project Color:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                              Navigator.pop(context);
                              _editProject(project);
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: color,
                              child:
                                  _selectedColor.value == color.value
                                      ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final projectProvider = Provider.of<ProjectProvider>(
                      context,
                      listen: false,
                    );

                    final updatedProject = Project(
                      id: project.id,
                      name: _nameController.text.trim(),
                      color: _selectedColor.value.toRadixString(16),
                    );

                    projectProvider.updateProject(updatedProject);

                    _nameController.clear();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project updated successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteProject(String projectId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Deleting this project will also delete all associated tasks and time entries. This action cannot be undone. Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  final projectProvider = Provider.of<ProjectProvider>(
                    context,
                    listen: false,
                  );
                  final taskProvider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );
                  final timeEntryProvider = Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  );

                  // Delete project, associated tasks, and time entries
                  projectProvider.deleteProject(projectId);
                  taskProvider.deleteTasksByProjectId(projectId);

                  // Delete time entries for this project
                  final entries = timeEntryProvider.getEntriesByProject(
                    projectId,
                  );
                  for (final entry in entries) {
                    timeEntryProvider.deleteEntry(entry.id);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project deleted successfully'),
                    ),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    return Scaffold(
      body:
          projects.isEmpty
              ? const Center(
                child: Text(
                  'No projects yet.\nTap the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final color = Color(int.parse(project.color, radix: 16));

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        project.name.isNotEmpty
                            ? project.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(project.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editProject(project),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(project.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TasksTab extends StatefulWidget {
  const TasksTab({Key? key}) : super(key: key);

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedProjectId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addTask() {
    // Reset form fields
    _nameController.clear();
    _selectedProjectId = null;

    showDialog(
      context: context,
      builder: (context) {
        final projectProvider = Provider.of<ProjectProvider>(context);
        final projects = projectProvider.projects;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Task'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProjectId,
                      hint: const Text('Select a project'),
                      items:
                          projects.map((project) {
                            return DropdownMenuItem<String>(
                              value: project.id,
                              child: Text(project.name),
                            );
                          }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a project';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );

                      final newTask = Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        projectId: _selectedProjectId!,
                      );

                      taskProvider.addTask(newTask);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task added successfully'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editTask(Task task) {
    _nameController.text = task.name;
    _selectedProjectId = task.projectId;

    showDialog(
      context: context,
      builder: (context) {
        final projectProvider = Provider.of<ProjectProvider>(context);
        final projects = projectProvider.projects;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProjectId,
                      hint: const Text('Select a project'),
                      items:
                          projects.map((project) {
                            return DropdownMenuItem<String>(
                              value: project.id,
                              child: Text(project.name),
                            );
                          }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a project';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );

                      final updatedTask = Task(
                        id: task.id,
                        name: _nameController.text.trim(),
                        projectId: _selectedProjectId!,
                      );

                      taskProvider.updateTask(updatedTask);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task updated successfully'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Deleting this task will also delete all associated time entries. This action cannot be undone. Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  final taskProvider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );
                  final timeEntryProvider = Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  );

                  // Delete task
                  taskProvider.deleteTask(taskId);

                  // Delete time entries for this task
                  final entries =
                      timeEntryProvider.entries
                          .where((entry) => entry.taskId == taskId)
                          .toList();
                  for (final entry in entries) {
                    timeEntryProvider.deleteEntry(entry.id);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted successfully')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      body:
          tasks.isEmpty
              ? const Center(
                child: Text(
                  'No tasks yet.\nTap the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final project = projectProvider.getProjectById(
                    task.projectId,
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          project != null
                              ? Color(int.parse(project.color, radix: 16))
                              : Colors.grey,
                      child: Text(
                        task.name.isNotEmpty ? task.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(task.name),
                    subtitle: Text(project?.name ?? 'Unknown Project'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTask(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
