import 'package:flutter/material.dart';

class Stock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
  });
}

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final List<Stock> _stocks = [
    Stock(symbol: 'AAPL', name: 'Apple Inc.', price: 172.29, change: 2.54, changePercent: 1.50),
    Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', price: 138.59, change: -1.12, changePercent: -0.80),
    Stock(symbol: 'MSFT', name: 'Microsoft Corp.', price: 370.95, change: 1.82, changePercent: 0.49),
    Stock(symbol: 'AMZN', name: 'Amazon.com, Inc.', price: 146.88, change: -0.78, changePercent: -0.53),
    Stock(symbol: 'TSLA', name: 'Tesla, Inc.', price: 234.30, change: 5.60, changePercent: 2.45),
    Stock(symbol: 'NVDA', name: 'NVIDIA Corporation', price: 471.65, change: -3.45, changePercent: -0.73),
    Stock(symbol: 'META', name: 'Meta Platforms, Inc.', price: 334.83, change: 2.10, changePercent: 0.63),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: _stocks.length,
        itemBuilder: (context, index) {
          final stock = _stocks[index];
          final isPositive = stock.change >= 0;
          final color = isPositive ? Colors.green : Colors.red;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.name,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${stock.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
