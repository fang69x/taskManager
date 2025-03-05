import express from 'express'
import { createTask } from '../controller/taskController.js'
const router=express.Router();

router.post('/tasks',createTask);


export default router;