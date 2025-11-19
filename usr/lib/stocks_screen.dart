import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  factory Stock.fromJson(Map<String, dynamic> json, String name) {
    final quote = json['Global Quote'];
    if (quote == null || quote.isEmpty) {
      throw Exception('Invalid stock data format from API');
    }
    
    final String changePercentStr = quote['10. change percent'] ?? '0%';
    final double changePercent = double.parse(changePercentStr.replaceAll('%', ''));

    return Stock(
      symbol: quote['01. symbol'],
      name: name,
      price: double.parse(quote['05. price']),
      change: double.parse(quote['09. change']),
      changePercent: changePercent,
    );
  }
}

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  List<Stock> _stocks = [];
  bool _isLoading = true;
  String? _error;

  final Map<String, String> _stockSymbols = {
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com, Inc.',
    'TSLA': 'Tesla, Inc.',
    'NVDA': 'NVIDIA Corporation',
    'META': 'Meta Platforms, Inc.',
  };

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    const apiKey = 'demo'; 
    final List<Future<Stock>> futures = [];

    for (var entry in _stockSymbols.entries) {
      final symbol = entry.key;
      final name = entry.value;
      final url = 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';
      
      futures.add(
        http.get(Uri.parse(url)).then((response) {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['Global Quote'] != null && data['Global Quote'].isNotEmpty) {
              return Stock.fromJson(data, name);
            } else if (data['Note'] != null) {
              throw Exception('API call limit reached. Please wait and try again.');
            } else {
              throw Exception('Failed to parse stock data for $symbol');
            }
          } else {
            throw Exception('Failed to load stock data for $symbol. Status code: ${response.statusCode}');
          }
        })
      );
    }

    try {
      final stocks = await Future.wait(futures);
      if (mounted) {
        setState(() {
          _stocks = stocks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchStockData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchStockData,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }
    return ListView.builder(
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
    );
  }
}
