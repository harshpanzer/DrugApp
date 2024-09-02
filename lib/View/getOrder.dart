import 'package:drugapp/services/wallet_connect.dart';
import 'package:flutter/material.dart';


class GetOrderDetailsPage extends StatefulWidget {
  @override
  _GetOrderDetailsPageState createState() => _GetOrderDetailsPageState();
}

class _GetOrderDetailsPageState extends State<GetOrderDetailsPage> {
  final BlockchainService _blockchainService = BlockchainService();
  final _formKey = GlobalKey<FormState>();

  String orderId = '';
  List orderDetails = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _blockchainService.initialize();
  }

  Future<void> getOrderDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();

      try {
        orderDetails = await _blockchainService.getOrderDetails(orderId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order details retrieved successfully!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error retrieving order details: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Order Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Order ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the order ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  orderId = value!;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: isLoading ? null : getOrderDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Get Order Details'),
              ),
              SizedBox(height: 24.0),
              if (orderDetails.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    'Order Details:\n$orderDetails',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
