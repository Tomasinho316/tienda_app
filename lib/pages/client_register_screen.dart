import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  Future<void> registerClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('clients').add({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente registrado correctamente')),
      );

      nameController.clear();
      emailController.clear();
      addressController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'El nombre es obligatorio',
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Correo inválido',
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'La dirección es obligatoria',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : registerClient,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Registrar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}