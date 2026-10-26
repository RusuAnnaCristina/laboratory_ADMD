import 'package:flutter/material.dart';

class Todo {
  Todo(this.title, {this.done = false}) : id = _nextId++;

  static int _nextId=0;

  final int id;
  final String title;
  bool done;
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoState();
}

class _TodoState extends State<TodoScreen> {
  final _items = <Todo>[
    Todo('Go to grocery store'),
    Todo('Finish homework'),
  ];

  final _input = TextEditingController();
  final _scroll = ScrollController();

  void _add() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _items.add(Todo(text));
    });
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
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _input,
              decoration: const InputDecoration(
                labelText: 'New todo',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final todo = _items[index];
                return Dismissible(
                  key: ValueKey(todo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red),
                  onDismissed: (_) {
                    final removedIndex =
                        _items.indexWhere((t) => t.id == todo.id);
                    final removed = _items[removedIndex];

                    setState(() {
                      _items.removeAt(removedIndex);
                    });

                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Deleted "${removed.title}"'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                final at = removedIndex > _items.length
                                    ? _items.length
                                    : removedIndex;
                                _items.insert(at, removed);
                              });
                            },
                          ),
                        ),
                      );
                  },
                  child: TodoTile(
                    title: todo.title,
                    done: todo.done,
                    onChanged: (value) {
                      setState(() {
                        todo.done = value ?? false;
                      });
                    },
                  ),
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