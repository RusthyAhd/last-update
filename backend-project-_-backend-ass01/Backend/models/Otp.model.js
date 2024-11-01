const mongoose = require('mongoose');

// Define the OTP schema
const otpSchema = new mongoose.Schema({
    phoneNumber: { type: String, required: true },
    otp: { type: String, required: true },
    date: { type: Date, default: Date.now } // Pass Date.now without parentheses
}, { timestamps: true });

// Add TTL index to delete documents 2 minutes after creation
otpSchema.index({ date: 1 }, { expireAfterSeconds: 120 });

// Check if the model already exists to prevent OverwriteModelError
const OTPModel = mongoose.models.Otp || mongoose.model("Otp", otpSchema);

module.exports = OTPModel;
