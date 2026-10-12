
class BankAccount {
  late String accountNumber;
  final String holderName;
  double balance;
  final String? bankBranch;
  bool _isAccountNumberSet = false;

  BankAccount({
    required this.holderName,
    this.balance = 0.0,
    this.bankBranch,
  });

  void initializeAccount(String number) {
    accountNumber = number;
    _isAccountNumberSet = true;
  }

  bool isAccountNumberSet() => _isAccountNumberSet;

  String getDisplayAccountNumber() {
    return _isAccountNumberSet ? accountNumber : 'Account number not initialized';
  }
}