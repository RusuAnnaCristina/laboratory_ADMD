import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/todo_api.dart';
import '../../models/todo.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(const TodoState());

  final _api = TodoApi();

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      emit(TodoState(todos: await _api.fetchTodos()));
    } catch (_) {
      emit(state.copyWith(loading: false)); // don't spin forever on error
    }
  }

  void add(String title) {
    final nextId =
        state.todos.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1;
    emit(state.copyWith(todos: [
      ...state.todos,
      Todo(userId: 1, id: nextId, title: title, completed: false),
    ]));
  }

  void toggle(int id) => emit(state.copyWith(todos: [
        for (final t in state.todos)
          if (t.id == id) t.copyWith(completed: !t.completed) else t,
      ]));

  void remove(int id) => emit(state.copyWith(
        todos: state.todos.where((t) => t.id != id).toList(),
      ));

  void restore(Todo todo, int index) {
    final list = [...state.todos];
    list.insert(index > list.length ? list.length : index, todo);
    emit(state.copyWith(todos: list));
  }
}