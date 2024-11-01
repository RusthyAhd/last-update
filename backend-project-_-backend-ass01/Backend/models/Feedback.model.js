const mongoose = require('mongoose');

// Define the Owner schema
const feedSchema = new mongoose.Schema({
    email: { type: String, required: true },
    serviceProviderEmail: { type: String, required: true },
    name: { type: String, required: true },
    comment: { type: String, required: true },
    rating: { type: Number, required: true },
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const FeedbackModel = mongoose.model("Feedback", feedSchema);

module.exports = FeedbackModel;
