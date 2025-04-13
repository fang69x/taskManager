import {Task} from '../models/task.model.js'

// create a new task

export const createTask=async(req,res)=>{
    try {
        const {title,description}=req.body; // req.body mese hum title aur description le rahe hai
        const userId=req.user.userId;

        const newTask= new Task({title,description,user:userId});
        await newTask.save();
        res.status(201).json(newTask);
    } catch (error) {
        res.status(500).json({
            message:"Error creating a task",
            error:error.message
        });
    }
}
// get all task
export const getAllTask=async(req,res)=>{
    try {
        const userId=req.user.userId;
  const tasks= await Task.find({user:userId});
  res.status(200).json(tasks);      
    } catch (error) {
        res.status(500).json({
            message:"Error fetching tasks",
            error:error.message
        })
    }
};
//get a single task by ID

export const getTaskById=async(req,res)=>{
    try {
        const userId=req.user.userId;
        const task =await Task.findById({_id:req.params.id,user:userId});
        if(!task){
            return res.status(404).json({
                message:"Task not found",
                error:error.message
            })
        }
        res.status(200).json({task});
    } catch (error) {
        res.status(500).json({
            message:"Error fetching task",
            error:error.message
        })
    }
};
// update a task
export const updateTask=async(req,res)=>{
    try {
        const userId=req.user.userId;
        const updatedTask = await Task.findOneAndUpdate(
            { 
                _id: req.params.id,
                user: userId // Ensure task belongs to current user
            },
            req.body,
            { new: true }
        );
        if(!updatedTask){
      return res.status(404).json({message:"Task not found"});
        }
        res.status(200).json({
            updatedTask
        })
    } catch (error) {
        res.status(500).json({
            message:"Error updating task",
            error:error.message
        })
    }
};
// delete a task

export const deleteTask = async (req, res) => {
    try {
        const userId = req.user.userId;
        const deletedTask = await Task.findOneAndDelete({
            _id: req.params.id,
            user: userId // Ensure task belongs to current user
        });
        
        if (!deletedTask) {
            return res.status(404).json({
                message: "Task not found",
            });
        }
        
        res.status(200).json({ message: "Task deleted successfully" });
    } catch (error) {
        res.status(500).json({
            message: "Error deleting task",
            error: error.message
        });
    }
}