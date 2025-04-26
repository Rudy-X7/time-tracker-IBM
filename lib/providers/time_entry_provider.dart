import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/time_entry.dart';
import 'storage_helper.dart';

class TimeEntryProvider extends ChangeNotifier {
  final StorageHelper _storage = StorageHelper();
  List<TimeEntry> _entries = [];
  static const String STORAGE_KEY = 'time_entries';

  List<TimeEntry> get entries => [..._entries];

  Future<void> loadEntries() async {
    final data = await _storage.getData(STORAGE_KEY);

    if (data != null && data is List) {
      _entries =
          data
              .map((entry) => TimeEntry.fromJson(entry as Map<String, dynamic>))
              .toList();
      notifyListeners();
    }
  }

  Future<void> addEntry(TimeEntry entry) async {
    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> updateEntry(TimeEntry updatedEntry) async {
    final entryIndex = _entries.indexWhere(
      (entry) => entry.id == updatedEntry.id,
    );
    if (entryIndex >= 0) {
      _entries[entryIndex] = updatedEntry;
      await _saveEntries();
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((entry) => entry.id == entryId);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    await _storage.saveData(
      STORAGE_KEY,
      _entries.map((entry) => entry.toJson()).toList(),
    );
  }

  List<TimeEntry> getEntriesByProject(String projectId) {
    return _entries.where((entry) => entry.projectId == projectId).toList();
  }

  int getTotalTimeByProject(String projectId) {
    return _entries
        .where((entry) => entry.projectId == projectId)
        .fold(0, (sum, entry) => sum + entry.durationInMinutes);
  }
}
