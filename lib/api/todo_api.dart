import 'dart:math';

import 'package:dio/dio.dart';

import '../models/todo.dart';

class TodoApi {
  final _dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
  ));

  Future<List<Todo>> fetchTodos([String path = '/todos']) async {
    final res = await _dio.get(path);
    final raw = res.data as List<dynamic>;
    return raw
        .map((j) => Todo.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

/// Tries [op] up to [maxAttempts] times.
/// Delay doubles each time (400, 800, 1600, 3200 ms) plus random jitter.
Future<T> withRetry<T>(
  Future<T> Function() op, {
  int maxAttempts = 5,
  void Function(String message)? onLog,
}) async {
  final random = Random();
  for (var i = 0; ; i++) {
    try {
      return await op();
    } catch (e) {
      final reason = e is DioException
          ? (e.response?.statusCode?.toString() ?? e.type.name)
          : e.toString();

      if (i == maxAttempts - 1) {
        onLog?.call('Attempt ${i + 1} failed ($reason). Giving up.');
        rethrow;
      }

      final base = 400 * (1 << i); // exponential backoff
      final delay = base + random.nextInt(base); // + jitter
      onLog?.call('Attempt ${i + 1} failed ($reason), retrying in $delay ms');
      await Future.delayed(Duration(milliseconds: delay));
    }
  }
}