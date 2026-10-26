import 'package:flutter/material.dart';
import 'models/user.dart';
import 'models/bank_account.dart';
import 'models/library_item.dart';
import 'models/book.dart';
import 'models/magazine.dart';
import 'models/library.dart';
import 'screens/todo_screen.dart';

void main() {
  // --- Task 1 ---
  final users = [
    User(name: 'Maria', age: 21, email: 'maria@example.com'),
    User(name: 'Daniela', age: 30),
    User(name: 'Alex'),
  ];

  // --- Task 2 ---
  final account1 = BankAccount(
    holderName: 'Cristina Munteanu',
    balance: 1500.0,
    bankBranch: 'Cluj Central',
  )..initializeAccount('RO12BTRL0001');

  final account2 = BankAccount(
    holderName: 'Bogdan Rosu',
    balance: 50.0,
  )..initializeAccount('RO99BCR0002');
  // .. iti permite sa apelezi o metoda pe un obiect imediat dupa ce l ai creat si sa pastrezi obiectul si nu rezultatul metodei

  final account3 = BankAccount(
    holderName: 'Eliza Radu',
  );

  final accounts = [account1, account2, account3];

  // --- Task 3 ---
  final library = Library();
  final student = User(name: 'Maria');

  final book1 = Book(
    title: 'Crooked Kingdom',
    author: 'Leigh Bardugo',
    publishDate: DateTime.now().subtract(const Duration(days: 10)),
    isbn: '978-0132350884',
  );

  final book2 = Book(
    title: 'Maleficent',
  );

  final mag1 = Magazine(
    title: 'Night Circus',
    issueNumber: 42,
  );

  library.addItem(book1);
  library.addItem(book2);
  library.addItem(mag1);

  
  library.borrowItem(book1, student);

  final lab2Screen = Scaffold(
      appBar: AppBar(title: const Text('Lab 2')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('--- USERS (TASK 1) ---', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...users.map((u) => ListTile(
                title: Text(u.name),
                subtitle: Text('${u.getDisplayAge()} · ${u.email ?? "Not provided"}'),
              )),

          const ListTile(
            title: Text('--- BANK ACCOUNTS (TASK 2) ---', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...accounts.map((a) => ListTile(
                title: Text(a.holderName),
                subtitle: Text('${a.getDisplayAccountNumber()} · Branch: ${a.bankBranch ?? "N/A"} · Balance: ${a.balance}'),
              )),

          const ListTile(
            title: Text('--- LIBRARY (TASK 3) ---', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...library.items.map((item) {
            final authorText = item.author ?? 'Unknown Author';
            final statusText = item.isBorrowed
                ? 'Borrowed by ${item.borrower?.name}'
                : 'Available';
            return ListTile(
              title: Text(item.title),
              subtitle: Text('$authorText · Status: $statusText'),
            );
          }),
        ],
      ),
    );
    runApp(const MaterialApp(home: TodoScreen()));
}