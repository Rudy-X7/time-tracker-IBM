import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../providers/time_entry_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({Key? key}) : super(key: key);

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  String? _selectedProjectId;
  String? _selectedTaskId;
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
    @override
  void initState() {
    super.initState();
    // Load projects on init
    Future.microtask(() {
      Provider.of<ProjectProvider>(context, listen: false).loadProjects();
    });
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final projects = projectProvider.projects;
    final tasks = _selectedProjectId == null
        ? <Task>[]
        : taskProvider.getTasksByProjectId(_selectedProjectId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Project',
                border: OutlineInputBorder(),
              ),
              value: _selectedProjectId,
              items: projects.map((project) {
                return DropdownMenuItem<String>(
                  value: project.id,
                  child: Text(project.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                  _selectedTaskId = null;
                });
              },
              validator: (value) => value == null ? 'Please select a project' : null,
            ),
            const SizedBox(height: 16),

            // Task Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Task',
                border: OutlineInputBorder(),
              ),
              value: _selectedTaskId,
              items: tasks.map((task) {
                return DropdownMenuItem<String>(
                  value: task.id,
                  child: Text(task.name),
                );
              }).toList(),
              onChanged: _selectedProjectId == null
                  ? null
                  : (value) {
                      setState(() {
                        _selectedTaskId = value;
                      });
                    },
              validator: (value) => value == null ? 'Please select a task' : null,
            ),
            const SizedBox(height: 16),

            // Duration Inputs
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursController,
                    decoration: const InputDecoration(
                      labelText: 'Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        if (_minutesController.text.isEmpty) {
                          return 'Enter hours or minutes';
                        }
                      } else if (int.tryParse(value) == null || int.parse(value) < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _minutesController,
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        if (_hoursController.text.isEmpty) {
                          return 'Enter hours or minutes';
                        }
                      } else {
                        final minutes = int.tryParse(value);
                        if (minutes == null || minutes < 0 || minutes > 59) {
                          return 'Enter a valid number (0-59)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveTimeEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Time Entry',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTimeEntry() {
    if (_formKey.currentState!.validate()) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final totalMinutes = (hours * 60) + minutes;

      if (totalMinutes <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total time must be greater than 0')),
        );
        return;
      }

      final timeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _selectedProjectId!,
        taskId: _selectedTaskId!,
        durationInMinutes: totalMinutes,
        date: _selectedDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Provider.of<TimeEntryProvider>(context, listen: false).addEntry(timeEntry);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time entry added successfully')),
      );
      Navigator.pop(context, true);
    }
  }
}

