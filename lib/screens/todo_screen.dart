import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../todos/cubit/todo_cubit.dart';
import '../todos/cubit/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _filter = ValueNotifier<String>('');

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _filter.dispose();
    super.dispose();
  }

  void _add() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    context.read<TodoCubit>().add(text);
    _input.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            final done = state.todos.where((t) => t.completed).length;
            return Text('Lab 5 (Cubit) · $done done');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _input,
              decoration: const InputDecoration(
                labelText: 'New todo',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filter',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filter.value = value.trim().toLowerCase(),
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ValueListenableBuilder<String>(
                  valueListenable: _filter,
                  builder: (context, filter, _) {
                    final visible = filter.isEmpty
                        ? state.todos
                        : state.todos
                            .where((t) => t.title.toLowerCase().contains(filter))
                            .toList();
                    return ListView.builder(
                      controller: _scroll,
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final todo = visible[index];
                        return Dismissible(
                          key: ValueKey(todo.id),
                          direction: DismissDirection.endToStart,
                          background: Container(color: Colors.red),
                          onDismissed: (_) {
                            final cubit = context.read<TodoCubit>();
                            final at = cubit.state.todos
                                .indexWhere((t) => t.id == todo.id);
                            cubit.remove(todo.id);
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text('Deleted "${todo.title}"'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => cubit.restore(todo, at),
                                  ),
                                ),
                              );
                          },
                          child: TodoTile(
                            title: todo.title,
                            done: todo.completed,
                            onChanged: (_) =>
                                context.read<TodoCubit>().toggle(todo.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.title,
    required this.done,
    required this.onChanged,
  });

  final String title;
  final bool done;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(title),
      ),
    );
  }
}