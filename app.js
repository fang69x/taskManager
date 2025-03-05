import express from 'express';
import cors from 'cors';
import taskRoutes from './src/routes/taskRoutes.js';

const app = express();

// Middleware
app.use(cors());
app.use(express.json()); // Allows JSON data in requests

// Routes
app.use('/api', taskRoutes); // All task routes start with /api

export default app;