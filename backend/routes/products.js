import express from 'express';
import db from '../firebase.js';

const router = express.Router();
const collection = db.collection('products');

// Crear producto
router.post('/', async (req, res) => {
  try {
    const docRef = await collection.add(req.body);
    res.status(201).json({ id: docRef.id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Editar producto
router.put('/:id', async (req, res) => {
  try {
    await collection.doc(req.params.id).update(req.body);
    res.status(200).json({ message: 'Producto actualizado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Eliminar producto
router.delete('/:id', async (req, res) => {
  try {
    await collection.doc(req.params.id).delete();
    res.status(200).json({ message: 'Producto eliminado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;