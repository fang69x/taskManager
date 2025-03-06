import express from "express";
import { authenticateUser } from "../middleware/authMiddleware.js";
import { createTask, deleteTask, getAllTask, getTaskById, updateTask } from "../controller/taskController.js";

const router = express.Router();

// Define task-related routes with meaningful subpaths
router.post("/create", authenticateUser, createTask); // POST /api/tasks/create
router.get("/list", authenticateUser, getAllTask); // GET /api/tasks/list
router.get("/detail/:id", authenticateUser, getTaskById); // GET /api/tasks/detail/:id
router.put("/update/:id", authenticateUser, updateTask); // PUT /api/tasks/update/:id
router.delete("/remove/:id", authenticateUser, deleteTask); // DELETE /api/tasks/remove/:id

export default router;
