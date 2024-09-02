import 'package:drugapp/services/wallet_connect.dart';
import 'package:flutter/material.dart';

class RecordOrderPage extends StatefulWidget {
  @override
  _RecordOrderPageState createState() => _RecordOrderPageState();
}

class _RecordOrderPageState extends State<RecordOrderPage> {
  final BlockchainService blockchainService = BlockchainService();
  final _formKey = GlobalKey<FormState>();

  String senderSerial = '';
  String receiverSerial = '';
  String amount = '';
  String price = '';

  @override
  void initState() {
    super.initState();
    blockchainService.initialize();
  }

  void recordOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        var a= await blockchainService.recordOrder(
          senderSerial,
          BigInt.parse(amount),
          BigInt.parse(price),
          receiverSerial,
        );
        

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order recorded successfully!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error recording order: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Order'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Sender Serial',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sender serial';
                  }
                  return null;
                },
                onSaved: (value) {
                  senderSerial = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  amount = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
                onSaved: (value) {
                  price = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Receiver Serial',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the receiver serial';
                  }
                  return null;
                },
                onSaved: (value) {
                  receiverSerial = value!;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: recordOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
