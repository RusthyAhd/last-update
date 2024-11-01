const mongoose = require('mongoose');

// Define the Owner schema
const serviceSchema = new mongoose.Schema({
    service_id: { type: String, required: true },
    service: { type: String, required: true },
    name: { type: String, required: true },
    description: { type: String, required: true },
    service_provider_id: { type: String, required: true },
    service_category: { type: String, required: true },
    pic: { type: String, required: true },
    price: { type: Number, required: true },
    availability: { type: String,enum: ['Available', 'Unavailable'], required: true },
    available_days: { type: [String], required: true },
    available_hours: { type: String, required: true },
    condition: {type: String, required: true},
    location_long: { type: Number, required: true },
    location_lat: { type: Number, required: true },
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const ServiceModel = mongoose.model('Service', serviceSchema);

module.exports = ServiceModel;
