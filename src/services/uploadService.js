import cloudinary from "../utils/cloudinary.js";
import fs from 'fs';
// function to upload file to cloudinary

export const uploadToCloudinary =async(filePath)=>{
    try {
        //upload the file to cloudinary
        const result=await cloudinary.uploader.upload(filePath,{
            folder: 'task-manager-avatars', // Create a specific folder in Cloudinary
            width: 250,
            height: 250,
            crop: 'fill', // Automatically crop and resize the image
            gravity: 'face' // Focus on face if present
        });
        //remove temporary file after upload
        fs.unlinkSync(filePath);
        return{
            public_id:result.public_id,
            url:result.secure_url
        };
        
    } catch (error) {
        if(fs.existsSync(filePath)){
            fs.unlinkSync(filePath);
        }
        throw new Error(`Error uploading to Cloudinary:${error.message}`);
    }
};
// function to delete file from cloudinary
export const deleteFromCloudinary=async(publicId)=>{
try {
    if(!publicId)return null;
    const result=await cloudinary.uploader.destroy(publicId);
    return result;
    
} catch (error) {
    throw new Error(`Error deleting from Cloudinary :${error.message}`);
    
}
};

