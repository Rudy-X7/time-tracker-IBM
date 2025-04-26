import 'package:localstorage/localstorage.dart';

class StorageHelper {
  static final _instance = StorageHelper._internal();

  factory StorageHelper() {
    return _instance;
  }

  StorageHelper._internal();

  Future<void> initStorage() async {
    await initLocalStorage();
  }

  Future<void> saveData(String key, dynamic data) async {
    localStorage.setItem(key, data.toString());
  }

  dynamic getData(String key) {
    return localStorage.getItem(key);
  }

  Future<void> removeData(String key) async {
    localStorage.removeItem(key);
  }

  Future<void> clearAll() async {
    localStorage.clear();
  }
}
