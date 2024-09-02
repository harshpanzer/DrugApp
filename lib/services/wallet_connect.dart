import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Order {
  final String senderSerial;
  final int amount;
  final int price;
  final bool isDone;

  Order({
    required this.senderSerial,
    required this.amount,
    required this.price,
    required this.isDone,
  });
}

class BlockchainService {
  final String rpcUrl =
      "https://polygon-amoy.infura.io/v3/4c6cee5814554e5291bf2e3d457dd2fd";
  final String privateKey =
      "c68bf176e8e1094ce671c4a1b821f1f36a1dee88605226c74528c773a2792a2b";

  late Web3Client client;
  late EthPrivateKey credentials;
  late DeployedContract contract;

  final String contractAddress = "0x3A7D02Fb463A4Fbf30B470548e3DC70Df481Dc11";

  BlockchainService() {
    client = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  // Load the contract's ABI and initialize the contract
  Future<void> initialize() async {
    String abiCode =
        await rootBundle.loadString('assets/AcetiGuardTracker.json');
    contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'AcetiGuardTracker'),
        EthereumAddress.fromHex(contractAddress));
  }

  // Function to record an order
  Future<void> recordOrder(String senderSerial, BigInt amount, BigInt price,
      String receiverSerial) async {
    final recordOrderFunction = contract.function('recordOrder');

    var a = await client.sendTransaction(
      credentials,
      chainId: 80002,
      Transaction.callContract(
        // gasPrice: EtherAmount.fromInt(EtherUnit.gwei, 1000),
        contract: contract,
        function: recordOrderFunction,
        parameters: [senderSerial, amount, price, receiverSerial],
      ),
    );
    print(a);
  }

  // Function to get order details by receiver's serial number
  Future<List<Order>> getOrderDetails(String receiverSerial) async {
    final getOrderDetailsFunction = contract.function('getOrderDetails');

    final result = await client.call(
      contract: contract,
      function: getOrderDetailsFunction,
      params: [receiverSerial],
    );

    List<Order> orderList = [];
    for (var order in result[0]) {
      orderList.add(Order(
        senderSerial: order[0],
        amount: order[1].toInt(),
        price: order[2].toInt(),
        isDone: order[3],
      ));
    }
    return orderList;
  }

  // Function to complete an order
  Future<String> completeOrder(String receiverSerial, BigInt orderIndex) async {
    final completeOrderFunction = contract.function('completeOrder');

    final result = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: completeOrderFunction,
        parameters: [receiverSerial, orderIndex],
      ),
    );
    return result;
  }

  // Function to get completed orders by receiver's serial number
  Future<List<dynamic>> getCompletedOrders(String receiverSerial) async {
    final getCompletedOrdersFunction = contract.function('getCompletedOrders');

    final result = await client.call(
      contract: contract,
      function: getCompletedOrdersFunction,
      params: [receiverSerial],
    );

    return result;
  }

}
