import 'package:drugapp/services/wallet_connect.dart';
import 'package:flutter/material.dart';

class CompleteOrderPage extends StatefulWidget {
  @override
  _CompleteOrderPageState createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {
  final BlockchainService _blockchainService = BlockchainService();
  List<Order> orders = [];
  String? selectedOrderIndex;
  String transactionHash = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      await     _blockchainService.initialize();

      // Fetch order details for receiver ID "123". Replace with actual receiver ID.
      List<Order> orderList = await _blockchainService.getOrderDetails('123');
      print(orderList[0]);
      setState(() {
        orders = orderList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching order details: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> completeOrder(int index) async {
    if (index < 0 || index >= orders.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid order index'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var a = await _blockchainService.completeOrder('123', BigInt.from(index));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order completed successfully!,$a'),
        backgroundColor: Colors.green,
      ));
      // Refresh the list after completion
      fetchOrderDetails();
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
            if (orders.isEmpty)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Order Index: $index'),
                      subtitle: Text(
                          'Sender: ${orders[index].senderSerial}\nAmount: ${orders[index].amount}\nPrice: ${orders[index].price}\nStatus: ${orders[index].isDone ? 'Completed' : 'Pending'}'),
                      tileColor: selectedOrderIndex == index.toString()
                          ? Colors.blue[100]
                          : Colors.white,
                      onTap: () {
                        setState(() {
                          selectedOrderIndex = index.toString();
                        });
                      },
                      trailing: selectedOrderIndex == index.toString()
                          ? Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                    );
                  },
                ),
              ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: isLoading || selectedOrderIndex == null
                  ? null
                  : () => completeOrder(int.parse(selectedOrderIndex!)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Complete Selected Order'),
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
