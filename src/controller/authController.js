import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.model.js";
import { uploadToCloudinary, deleteFromCloudinary } from "../services/uploadService.js";
import fs from 'fs';

// Register user
export const registerUser = async (req, res) => {
    try {
        // Take name, email and password from the body
        const { name, email, password } = req.body;
        
        // Check if it already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            // Remove uploaded file if user registration fails
            if (req.file) {
                fs.unlinkSync(req.file.path);
            }
            return res.status(400).json({
                message: "User already exists"
            });
        }
        
        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);
        
        // Handle avatar upload if file is provided
        let avatarData = {};
        if (req.file) {
            avatarData = await uploadToCloudinary(req.file.path);
        }
        
        // Create a new user and pass the hashed password in it
        const newUser = new User({
            name,
            email,
            password: hashedPassword,
            avatar: avatarData
        });
        
        // Save the new user
        await newUser.save();
        
        // Generate JWT token
        const token = jwt.sign(
            {
                userId: newUser._id
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "1h",
            }
        );
        
        res.status(201).json({
            message: "User registered successfully",
            token,
            user: {
                id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                avatar: newUser.avatar?.url || null
            }
        });
    } catch (error) {
        // Clean up file if registration fails
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        
        res.status(500).json({
            message: "Error registering user",
            error: error.message
        });
    }
};

// Login user
export const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: "User not found" });
        }

        // Compare passwords
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid credentials" });
        }

        // Generate JWT Token
        const token = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "1h" }
        );

        res.status(200).json({
            message: "Login successful",
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                avatar: user.avatar?.url || null
            }
        });

    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ message: "Error logging in", error: error.message || error });
    }
};

// Update avatar
export const updateAvatar = async (req, res) => {
    try {
        // Get user from authentication middleware
        const userId = req.user.userId;
        
        if (!req.file) {
            return res.status(400).json({ message: "No file uploaded" });
        }
        
        // Find the user
        const user = await User.findById(userId);
        if (!user) {
            // Clean up file if user not found
            fs.unlinkSync(req.file.path);
            return res.status(404).json({ message: "User not found" });
        }
        
        // If user already has an avatar, delete it from Cloudinary
        if (user.avatar && user.avatar.public_id) {
            await deleteFromCloudinary(user.avatar.public_id);
        }
        
        // Upload new avatar to Cloudinary
        const avatarData = await uploadToCloudinary(req.file.path);
        
        // Update user's avatar
        user.avatar = avatarData;
        await user.save();
        
        res.status(200).json({
            message: "Avatar updated successfully",
            avatar: user.avatar
        });
    } catch (error) {
        // Clean up file if update fails
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        
        res.status(500).json({
            message: "Error updating avatar",
            error: error.message
        });
    }
};

// Get current user profile
export const getProfile = async (req, res) => {
    try {
        const userId = req.user.userId;
        
        const user = await User.findById(userId).select('-password');
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        
        res.status(200).json({
            user
        });
    } catch (error) {
        res.status(500).json({
            message: "Error fetching user profile",
            error: error.message
        });
    }
};