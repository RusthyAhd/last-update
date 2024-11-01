const mongoose = require('mongoose');

// Define the Owner schema
const OwnerSchema = new mongoose.Schema({
    name: { type: String, required: true },
    shop_name: { type: String, required: true },
    phone: { type: String, required: true },
    address: { type: String, required: true },
    location_long: { type: Number, required: true },
    location_lat: { type: Number, required: true },
    email: { type: String, required: true, unique: true }, // Ensure email is unique
    category: { type: String, required: true },
    password: { type: String, required: true }, // Add password field
    pic: { type: String, required: true },
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const OwnerModel = mongoose.model('Shopowner_register', OwnerSchema);

module.exports = OwnerModel;
