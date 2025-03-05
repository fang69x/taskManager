import {Task} from '../models/task.model.js'

// create a new task

export const createTask=async(req,res)=>{
    try {
        const {title,description}=req.body; // req.body mese hum title aur description le rahe hai
        const newTask= new Task({title,description});
        await newTask.save();
        res.status(201).json(newTask);
    } catch (error) {
        res.status(500).json({
            message:"Error creating a task",
            error:error.message
        });
    }
}