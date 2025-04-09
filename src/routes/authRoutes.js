import express from 'express';
import { registerUser, loginUser, updateAvatar, getProfile } from '../controller/authController.js';
import { authenticateUser } from '../middleware/authMiddleware.js';
import { upload } from '../middleware/uploadMiddleware.js';
import fs from 'fs';
import path from 'path';

// Create uploads directory if it doesn't exist
const uploadDir = './tmp/uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const router = express.Router();

// Auth routes
router.post("/signup", upload.single('avatar'), registerUser);
router.post("/login", loginUser);
router.put("/avatar", authenticateUser, upload.single('avatar'), updateAvatar);
router.get("/profile", authenticateUser, getProfile);

export default router;