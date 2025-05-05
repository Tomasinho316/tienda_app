import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController emailController = TextEditingController();
  Map<String, dynamic>? clientData;
  bool clientNotFound = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      final email = emailController.text.trim();
      if (email.contains('@')) {
        fetchClientData(email);
      } else {
        setState(() {
          clientData = null;
          clientNotFound = false;
        });
      }
    });
  }

  Future<void> fetchClientData(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('clients')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        clientData = query.docs.first.data();
        clientNotFound = false;
      });
    } else {
      setState(() {
        clientData = null;
        clientNotFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Carro de Compras')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo del cliente'),
            ),
            const SizedBox(height: 10),
            if (clientData != null) ...[
              Text('Nombre: ${clientData!['name'] ?? '-'}'),
              Text('Correo: ${clientData!['email'] ?? '-'}'),
              Text('Dirección: ${clientData!['address'] ?? '-'}'),
            ] else if (clientNotFound)
              const Text(
                'Cliente no registrado',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final product = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          '\$${product.price.toStringAsFixed(0)} x${product.quantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => cart.removeItem(product.id),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: \$${cart.total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: clientData == null
                  ? null
                  : () async {
                      final email = emailController.text.trim();

                      final success = await cart.checkout(email);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Compra realizada con éxito')),
                        );
                        setState(() {
                          cart.clearCart();
                          emailController.clear();
                          clientData = null;
                          clientNotFound = false;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al procesar la compra')),
                        );
                      }
                    },
              child: const Text('Finalizar Compra'),
            ),
          ],
        ),
      ),
    );
  }
}
