import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String _id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int stock;
  final int quantity;

  Product({
    String? id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    this.quantity = 1,
  }) : _id = id ?? '';

  // Getter y setter para el ID
  String get id => _id;
  set id(String value) => _id = value;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'stock': stock,
    };
  }

  Product copyWith({int? quantity}) {
    return Product(
      id: _id,
      name: name,
      category: category,
      description: description,
      price: price,
      stock: stock,
      quantity: quantity ?? this.quantity,
    );
  }
}