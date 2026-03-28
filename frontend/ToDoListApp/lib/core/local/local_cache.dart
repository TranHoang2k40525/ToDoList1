import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalCache {
  static const _tokenKey = 'auth_token';
  static const _todoCacheKey = 'todo_cache';
  static const _profileCacheKey = 'profile_cache';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveTodoCache(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todoCacheKey, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getTodoCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todoCacheKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveProfileCache(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileCacheKey, jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getProfileCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileCacheKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
