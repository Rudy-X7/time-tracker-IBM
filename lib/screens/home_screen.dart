import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _isGroupedByProject = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(
      context,
      listen: false,
    );
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await Future.wait([
      timeEntryProvider.loadEntries(),
      projectProvider.loadProjects(),
      taskProvider.loadTasks(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            icon: Icon(_isGroupedByProject ? Icons.list : Icons.folder),
            onPressed: () {
              setState(() {
                _isGroupedByProject = !_isGroupedByProject;
              });
            },
            tooltip: _isGroupedByProject ? 'Show as list' : 'Group by project',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectTaskManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTimeEntriesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTimeEntryScreen()),
          );

          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimeEntriesList() {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final entries = timeEntryProvider.entries;

    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No time entries yet.\nTap the + button to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    if (_isGroupedByProject) {
      return _buildGroupedByProjectList(entries, projectProvider, taskProvider);
    } else {
      return _buildFlatList(entries, projectProvider, taskProvider);
    }
  }

  Widget _buildFlatList(
    List<TimeEntry> entries,
    ProjectProvider projectProvider,
    TaskProvider taskProvider,
  ) {
    // Sort entries by date (newest first)
    final sortedEntries = List<TimeEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final project = projectProvider.getProjectById(entry.projectId);
        final task = taskProvider.getTaskById(entry.taskId);

        return _buildTimeEntryCard(entry, project, task);
      },
    );
  }

  Widget _buildGroupedByProjectList(
    List<TimeEntry> entries,
    ProjectProvider projectProvider,
    TaskProvider taskProvider,
  ) {
    // Group entries by project
    final groupedEntries = groupBy(entries, (TimeEntry e) => e.projectId);
    final projectIds = groupedEntries.keys.toList();

    return ListView.builder(
      itemCount: projectIds.length,
      itemBuilder: (context, index) {
        final projectId = projectIds[index];
        final project = projectProvider.getProjectById(projectId);
        final projectEntries = groupedEntries[projectId]!;

        // Sort entries by date (newest first)
        projectEntries.sort((a, b) => b.date.compareTo(a.date));

        return ExpansionTile(
          title: Text(project?.name ?? 'Unknown Project'),
          subtitle: Text(
            'Total: ${_formatDuration(projectEntries.fold(0, (sum, e) => sum + e.durationInMinutes))}',
          ),
          children:
              projectEntries.map((entry) {
                final task = taskProvider.getTaskById(entry.taskId);
                return _buildTimeEntryCard(entry, project, task);
              }).toList(),
        );
      },
    );
  }

  Widget _buildTimeEntryCard(TimeEntry entry, Project? project, Task? task) {
    return Dismissible(
      key: Key(entry.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final timeEntryProvider = Provider.of<TimeEntryProvider>(
          context,
          listen: false,
        );
        timeEntryProvider.deleteEntry(entry.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Time entry deleted')));
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm'),
                content: const Text(
                  'Are you sure you want to delete this time entry?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project?.name ?? 'Unknown Project',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(entry.durationInMinutes),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task?.name ?? 'Unknown Task',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(entry.date)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${entry.notes}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}
