import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Servicio para gestionar la autenticación y sesión del usuario
class AuthService {
  // Keys para SharedPreferences
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Singleton pattern para tener una única instancia
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Cache en memoria
  int? _userId;
  String? _username;
  Map<String, dynamic>? _userData;

  /// Guardar sesión del usuario
  Future<void> saveUserSession({
    required int userId,
    required String username,
    Map<String, dynamic>? userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Guardar en SharedPreferences
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsLoggedIn, true);
    
    if (userData != null) {
      await prefs.setString(_keyUserData, jsonEncode(userData));
    }
    
    // Guardar en cache
    _userId = userId;
    _username = username;
    _userData = userData;
    
    print('✅ Sesión guardada: Usuario $userId ($username)');
  }

  /// Obtener el ID del usuario actual
  Future<int?> getUserId() async {
    // Si ya está en cache, retornar
    if (_userId != null) return _userId;
    
    // Si no, obtener de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(_keyUserId);
    
    return _userId;
  }

  /// Obtener el ID del usuario de forma síncrona (desde cache)
  int? get currentUserId => _userId;

  /// Obtener el username del usuario actual
  Future<String?> getUsername() async {
    if (_username != null) return _username;
    
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_keyUsername);
    
    return _username;
  }

  /// Obtener el username de forma síncrona (desde cache)
  String? get currentUsername => _username;

  /// Obtener todos los datos del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    if (_userData != null) return _userData;
    
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    
    if (userDataString != null) {
      _userData = jsonDecode(userDataString);
    }
    
    return _userData;
  }

  /// Verificar si hay una sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Limpiar SharedPreferences
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
    
    // Limpiar cache
    _userId = null;
    _username = null;
    _userData = null;
    
    print('✅ Sesión cerrada');
  }

  /// Cargar sesión al iniciar la app
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    _userId = prefs.getInt(_keyUserId);
    _username = prefs.getString(_keyUsername);
    
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      _userData = jsonDecode(userDataString);
    }
    
    if (_userId != null) {
      print('✅ Sesión cargada: Usuario $_userId ($_username)');
    } else {
      print('ℹ️ No hay sesión guardada');
    }
  }

  /// Actualizar datos del usuario
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userData));
    _userData = userData;
  }

  /// Obtener información completa del usuario
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await getUserId();
    if (userId == null) return null;

    return {
      'id': userId,
      'username': await getUsername(),
      'data': await getUserData(),
    };
  }
}