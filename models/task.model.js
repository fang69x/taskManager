import mongoose from "mongoose";

const taskSchema= new Schema({
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
    }

},{
    timestamps:true,
});

export const Task=mongoose.model("Task",taskSchema)

