import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _products.clear();
      for (var doc in snapshot.docs) {
        _products.add(Product.fromFirestore(doc));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error recibiendo productos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      product.id = docRef.id;
      _products.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint('Error añadiendo producto: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) return;
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error actualizando producto: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error borrando producto: $e');
    }
  }

  Future<void> reduceStock(String productId, int quantity) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      final currentStock = doc.data()?['stock'] ?? 0;

      if (currentStock >= quantity) {
        await _firestore.collection('products').doc(productId).update({
          'stock': currentStock - quantity,
        });
        await fetchProducts();
      }
    } catch (e) {
      debugPrint('Error restando stock: $e');
    }
  }
}