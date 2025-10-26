import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static const String supabaseUrl = 'https://wtombxsgdeepkedttlhl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0b21ieHNnZGVlcGtlZHR0bGhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNjA5NjksImV4cCI6MjA3NjkzNjk2OX0.glvqwsbmjA3qAJqsrIXSnEnEbsuw9tnmvcrEWl28vQ4';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
