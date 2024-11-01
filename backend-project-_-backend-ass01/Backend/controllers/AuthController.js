const CustomResponse = require('../utils/custom.response');
const OTPModel = require("../models/Otp.model");
const bcrypt = require("bcrypt");
const ProfileModel = require("../models/Profile.model");
const jwt = require('jsonwebtoken');

exports.verifyOtp = async (req, res, next) => {
    const { otp, phoneNumber } = req.body;

    // Check if OTP and phone number are provided
    if (!otp || !phoneNumber) {
        return res.status(404).send(
            new CustomResponse(
                404,
                'Details incomplete! Please check and try again.'
            )
        );
    }

    try {
        // Retrieve OTP entry from the database
        const otpEntry = await OTPModel.findOne({ phoneNumber });

        if (!otpEntry) {
            return res.status(400).send(
                new CustomResponse(
                    403,
                    'OTP has expired or does not exist'
                )
            );
        }

        // Compare the provided OTP with the stored (hashed) OTP
        const isValidOtp = await bcrypt.compare(otp, otpEntry.otp);

        if (!isValidOtp) {
            return res.status(400).send(
                new CustomResponse(
                    403,
                    'Invalid OTP'
                )
            );
        }

        // Find a profile by phoneNumber
        let profile = await ProfileModel.findOne({ phoneNumber });

        // If no profile exists, create a new one
        if (!profile) {
            const newProfile = new ProfileModel({
                fullName: "new user",
                phoneNumber,
                email: "",
                birthday: "",
                gender: "Other",
                address: "",
                location: "",
                profilePhoto: ""
            });

            // Save the profile to the database
            profile = await newProfile.save();
            console.log(profile);
        }

        // Generate token
        const token = await this.generateJwtToken(profile);

        // Delete OTP from the database (optional)
        await OTPModel.deleteOne({ phoneNumber });

        // Send successful response
        return res.status(200).send(
            new CustomResponse(
                200,
                'OTP verified successfully',
                {
                    token: token,
                    user: profile
                }
            )
        );

    } catch (error) {
        console.error(error);
        return res.status(500).send(
            new CustomResponse(500, `Error: ${error.message}`)
        );
    }
};

// Generate JWT token function
exports.generateJwtToken = async (profile) => {
    const expiresIn = process.env.TOKEN_EX || "40w"; // Token expiration time
    const payload = { user: profile };

    // Return a new token signed with the secret key
    return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
};
