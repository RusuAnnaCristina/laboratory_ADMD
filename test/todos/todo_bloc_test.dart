import 'package:bloc_test/bloc_test.dart';
import 'package:lab1_app/models/todo.dart';
import 'package:lab1_app/todos/bloc/todo_bloc.dart';
import 'package:lab1_app/todos/bloc/todo_event.dart';
import 'package:lab1_app/todos/bloc/todo_state.dart';
import 'package:lab1_app/todos/todo_repository.dart';
import 'package:mocktail/mocktail.dart';

class FakeTodoRepository extends Mock implements TodoRepository {}

void main() {
  final repo = FakeTodoRepository();

  blocTest<TodoBloc, TodoState>(
    'add then toggle emits two states in order',
    build: () => TodoBloc(repo),
    act: (bloc) => bloc
      ..add(AddTodo('Milk'))
      ..add(ToggleTodo(1)),
    expect: () => [
      const TodoState(
        todos: [Todo(userId: 1, id: 1, title: 'Milk', completed: false)],
      ),
      const TodoState(
        todos: [Todo(userId: 1, id: 1, title: 'Milk', completed: true)],
      ),
    ],
  );
}