import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import taskRoutes from "./src/routes/taskRoutes.js";
import authRoutes from "./src/routes/authRoutes.js"; 
import { authenticateUser } from "./src/middleware/authMiddleware.js"

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json()); // Allows JSON data in requests

// Routes
app.use("/api/tasks", authenticateUser, taskRoutes); // Protect task routes with authentication
app.use("/api/auth", authRoutes); // Separate prefix for auth routes

export default app;
