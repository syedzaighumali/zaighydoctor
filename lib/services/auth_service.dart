import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final String _baseUrl = kIsWeb 
      ? 'http://localhost:5000/api' 
      : (defaultTargetPlatform == TargetPlatform.android 
          ? 'http://10.0.2.2:5000/api' 
          : 'http://localhost:5000/api');

  static Future<Map<String, dynamic>> register(String name, String email, String password, int age) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      final token = await userCredential.user?.getIdToken();
      if (token != null) {
        await http.put(
          Uri.parse('$_baseUrl/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'name': name, 'age': age}),
        );
      }

      return {'success': true, 'message': 'Registration successful'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'message': 'Login successful'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<bool> isLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  static Future<String?> getToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }
}
