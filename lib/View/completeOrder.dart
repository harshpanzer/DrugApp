import 'package:drugapp/services/wallet_connect.dart';
import 'package:flutter/material.dart';

class ShowCompleteOrderPage extends StatefulWidget {
  @override
  _ShowCompleteOrderPageState createState() => _ShowCompleteOrderPageState();
}

class _ShowCompleteOrderPageState extends State<ShowCompleteOrderPage> {
  final BlockchainService _blockchainService = BlockchainService();
  final _formKey = GlobalKey<FormState>();

  var receiverIds = [];
  String? selectedReceiverId;
  String transactionHash = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _blockchainService.initialize();
    fetchReceiverIds();
  }

  Future<void> fetchReceiverIds() async {
    // Fetch receiver IDs from blockchain
    try {
      var ids = await _blockchainService.getCompletedOrders("123");
      print(ids); // Replace with actual method to fetch IDs
      setState(() {
        receiverIds = ids;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching receiver IDs: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> completeOrder() async {
    if (selectedReceiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a receiver ID'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var transactionHash =
          await _blockchainService.completeOrder("123", BigInt.from(2));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order completed successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error completing order: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Order'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReceiverId,
              decoration: InputDecoration(
                labelText: 'Select Receiver ID',
                border: OutlineInputBorder(),
              ),
              items: receiverIds.map((id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(id),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReceiverId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a receiver ID';
                }
                return null;
              },
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: isLoading ? null : completeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Complete Order'),
            ),
            SizedBox(height: 24.0),
            if (transactionHash.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  'Transaction Hash:\n$transactionHash',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
