import 'package:flutter/material.dart';
import '../api/todo_api.dart';

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

  String? _filter;
  
  // --- Lab 4 Task II ---
  final _api = TodoApi();
  final _log = <String>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load('/todos');
  }

  void _addLog(String message) {
    debugPrint(message);
    if (!mounted) return;
    setState(() => _log.add(message));
  }

  Future<void> _load(String path) async {
    setState(() {
      _loading = true;
      _log.clear();
    });
    _addLog('GET $path');
    try {
      final todos = await withRetry(
        () => _api.fetchTodos(path),
        onLog: _addLog,
      );
      if (!mounted) return;
      setState(() {
        // turn each API todo into a Lab 3 Todo and add it to the list
        _items.addAll(todos.map((t) => Todo(t.title, done: t.completed)));
      });
      _addLog('Loaded ${todos.length} todos');
    } catch (_) {
      _addLog('Request to $path failed after all attempts');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  // --- end Lab 4 ---

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
  final filter = _filter;
    final visible = filter == null
        ? List<Todo>.of(_items)
        : _items.where((t) => t.title.contains(filter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Todos (${_countDone()} done)'),
        actions: [
          IconButton(
            tooltip: 'Test retry (invalid path)',
            icon: const Icon(Icons.bug_report),
            onPressed: _loading ? null : () => _load('/nope'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_log.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in _log)
                    Text(
                      line,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _input,
              decoration: const InputDecoration(
                labelText: 'New todo',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12,12,12,0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filter',
                border: OutlineInputBorder(),
               ),
               onChanged: (value){
                  setState(() {
                    _filter = value.isEmpty ? null : value;
                  });
               },
              ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final todo = visible[index];
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
                    onChanged: (_) => _toggle(_items.indexOf(todo)),
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
    void _toggle(int i) {
    setState(() {
      _items[i].done = !_items[i].done;
    });
  }
  int _countDone() {
    var done = 0;
    for (var i = 0; i < _items.length; i++) {
      done += _items[i].done ? 1 : 0;
    }
    return done;
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