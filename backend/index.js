import express from 'express';
import cors from 'cors';
import productRoutes from './routes/products.js';

const app = express();
app.use(cors());
app.use(express.json());

app.use('/products', productRoutes);

const PORT = process.env.PORT || 8010;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
