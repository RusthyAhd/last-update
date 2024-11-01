const mongoose = require('mongoose');

// Define the schema for service provider registration
const ServiceProviderSchema = new mongoose.Schema({
    name: { type: String, required: true },
    service_title: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    address: { type: String, required: true },
    location_long: { type: Number, required: true },
    location_lat: { type: Number, required: true },
    email: { type: String, required: true, unique: true },
    category: { type: String, required: true },
    description: { type: String, required: true },
    password: { type: String, required: true },
    pic: { type: String, required: true }
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const ServiceProviderModel = mongoose.models.ServiceProviderdetail || mongoose.model('ServiceProviderdetail', ServiceProviderSchema);

module.exports = ServiceProviderModel;
