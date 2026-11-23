import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../todos/bloc/todo_bloc.dart';
import '../todos/bloc/todo_event.dart';
import '../todos/cubit/todo_cubit.dart';
import '../todos/todo_repository.dart';
import 'todo_screen.dart';
import 'todo_screen_cubit.dart' show TodoScreenCubit;
import 'todo_screen_lab4.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADMD Labs')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TodoScreenLab4()),
              ),
              child: const Text('Lab 4: setState + retry'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => TodoCubit()..load(),
                    child: const TodoScreenCubit(),
                  ),
                ),
              ),
              child: const Text('Lab 5 Task I: Cubit'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        TodoBloc(TodoRepository(Dio()))..add(LoadTodos()),
                    child: const TodoScreen(),
                  ),
                ),
              ),
              child: const Text('Lab 5 Task II: Bloc'),
            ),
          ],
        ),
      ),
    );
  }
}