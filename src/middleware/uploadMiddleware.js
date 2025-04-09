import multer from 'multer'
import path from 'path'

//set storage engine
const storage=multer.diskStorage({
    destination:function(req,file,cb){
        cb(null, './tmp/uploads');
    },
    //timestamps in filename to avoid conflicts
    filename:function(req,file,cb){
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

export const upload=multer({
    storage:storage,
    limits: { fileSize: 1024 * 1024 * 5 }, // Limit file size to 5MB

});