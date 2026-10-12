import 'package:flutter/material.dart';
import 'models/user.dart';

void main() {
  final users = [
    User(name: 'Ana', age: 21, email: 'ana@example.com'),
    User(name: 'Mihai', age: 30),
    User(name: 'Ioana'),
  ];

  runApp(MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.getDisplayAge()} · ${u.email ?? 'Not provided'}'),
          );
        },
      ),
    ),
  ));
}