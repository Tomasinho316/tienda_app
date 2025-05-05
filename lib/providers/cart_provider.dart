import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, Product> _items = {};
  final _firestore = FirebaseFirestore.instance;

  Map<String, Product> get items => _items;

  double get total {
    double total = 0.0;
    _items.forEach((_, product) {
      total += product.price * product.quantity;
    });
    return total;
  }

  int get totalItems {
    int count = 0;
    _items.forEach((_, product) {
      count += product.quantity;
    });
    return count;
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => existing.copyWith(quantity: existing.quantity + 1),
      );
    } else {
      _items[product.id] = product.copyWith(quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout(String email) async {
    try {
      final batch = _firestore.batch();
      List<String> outOfStockProducts = [];

      for (var entry in _items.entries) {
        final docRef = _firestore.collection('products').doc(entry.key);
        final snapshot = await docRef.get();

        if (!snapshot.exists) continue;

        final currentStock = snapshot['stock'] as int;
        final cartQuantity = entry.value.quantity;

        if (currentStock >= cartQuantity) {
          batch.update(docRef, {
            'stock': currentStock - cartQuantity,
          });

          // Guardar venta
          final saleData = {
            'productId': entry.key,
            'quantity': cartQuantity,
            'total': entry.value.price * cartQuantity,
            'email': email,
            'timestamp': FieldValue.serverTimestamp(),
          };
          batch.set(_firestore.collection('sales').doc(), saleData);
        } else {
          outOfStockProducts.add(entry.key);
        }
      }

      // Si hay productos sin stock, se remueve y cancela la compra
      if (outOfStockProducts.isNotEmpty) {
        for (var id in outOfStockProducts) {
          _items.remove(id);
        }
        notifyListeners();
        return false;
      }

      await batch.commit();
      clearCart();
      return true;
    } catch (e) {
      debugPrint('Error en checkout: $e');
      return false;
    }
  }
}
