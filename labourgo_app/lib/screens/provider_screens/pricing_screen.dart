import 'package:flutter/material.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final serviceController = TextEditingController();
  final priceController = TextEditingController();

  final List<Map<String, String>> services = [];

  @override
  void dispose() {
    serviceController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _addService() {
    final service = serviceController.text.trim();
    final price = priceController.text.trim();

    if (service.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter service and price')),
      );
      return;
    }

    setState(() {
      services.add({
        'service': service,
        'price': price,
      });
    });

    serviceController.clear();
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: serviceController,
              decoration: const InputDecoration(labelText: 'Service'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addService,
              child: const Text('Add'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(services[index]['service'] ?? ''),
                    trailing: Text('PKR ${services[index]['price'] ?? ''}'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
