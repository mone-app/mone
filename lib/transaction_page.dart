// transaction_page.dart

import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi')),
      body: Center(
        child: Text('Halaman untuk mencatat transaksi.'),
      ),
    );
  }
}