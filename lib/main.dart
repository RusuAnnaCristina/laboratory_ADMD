import 'package:flutter/material.dart';
import 'models/bank_account.dart';

void main() {
  final account1 = BankAccount(
    holderName: 'Alice Popescu',
    balance: 1500.0,
    bankBranch: 'Cluj Central',
  )..initializeAccount('RO12BTRL0001');

  final account2 = BankAccount(
    holderName: 'Bogdan Ionescu',
    balance: 50.0,
  )..initializeAccount('RO99BCR0002');

  
  final account3 = BankAccount(
    holderName: 'Cristina Radu',
    balance: 0.0,
  );

  final accounts = [account1, account2, account3];

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Lab 2 - Task II')),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, i) {
          final a = accounts[i];
          final branchText = a.bankBranch ?? 'N/A';
          final accNumberText = a.getDisplayAccountNumber();

          return ListTile(
            title: Text(a.holderName),
            subtitle: Text('$accNumberText · Branch: $branchText · Balance: ${a.balance}'),
          );
        },
      ),
    ),
  ));
}