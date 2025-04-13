import mongoose from "mongoose";

const taskSchema= new mongoose.Schema({
    title:{
        type:String ,
        required:true,
    },
    decription:{
        type:String ,
    },
    status:{
      type:String,
      enum:['pending','in-progess','completed'],
      default:'pending',
    },
    user:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'User',
        required:true,

    }

},{
    timestamps:true,
});

export const Task=mongoose.model("Task",taskSchema)

