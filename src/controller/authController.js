import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.model.js";

// regiter user

export const registerUser=async(req,res)=>{
    try {
        // take name user and password from the body
        const {name, email, password}=req.body;
        // check if it already exsit
        const existingUser=await User.findOne({email});
        if(existingUser){
            return res.status(400).json({
                message:"User already exists"
            });
        }
        // hash the password
        const hashedPassword= await bcrypt.hash(password,10);
        // create a new user and pass the hashed password in it
        const newUser=new User({
            name,email,password:hashedPassword
        });
        // save the new user
        await newUser.save();
// generate jwt token
const token=jwt.sign(
    {
        userId:newUser._id
    },
    process.env.JWT_SECRET,
    {
        expiresIn:"1h",
    }
)
        res.status(201).json({
            message:"User registered successfully",
            token
        })
    } catch (error) {
        res.status(500).json({
            message:"Error registering user",
            error 
        })    
    }
};

// login user
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
        });

    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ message: "Error logging in", error: error.message || error });
    }
};
