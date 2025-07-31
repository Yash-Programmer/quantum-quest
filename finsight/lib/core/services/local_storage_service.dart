import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  factory LocalStorageService() {
    return _instance ?? LocalStorageService._();
  }

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    await init();
    return await _preferences!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _preferences!.getString(key);
  }

  // Integer operations
  Future<bool> setInt(String key, int value) async {
    await init();
    return await _preferences!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await init();
    return _preferences!.getInt(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    await init();
    return await _preferences!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await init();
    return _preferences!.getDouble(key);
  }

  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    await init();
    return await _preferences!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await init();
    return _preferences!.getBool(key);
  }

  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return await _preferences!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await init();
    return _preferences!.getStringList(key);
  }

  // Remove operations
  Future<bool> remove(String key) async {
    await init();
    return await _preferences!.remove(key);
  }

  Future<bool> clear() async {
    await init();
    return await _preferences!.clear();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    await init();
    return _preferences!.containsKey(key);
  }

  // Get all keys
  Future<Set<String>> getKeys() async {
    await init();
    return _preferences!.getKeys();
  }
}
