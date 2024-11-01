const mongoose = require('mongoose');

// Define the Owner schema
const serviceOrderSchema = new mongoose.Schema({
    order_id: { type: String, required: true },
    service_id: { type: String, required: true },
    provider_id: { type: String, required: true },
    customer_id: { type: String, required: true },
    customer_name: { type: String, required: true },
    customer_address: { type: String, required: true },
    customer_location: { type: String, required: true },
    customer_number: { type: String, required: true },
    description: { type: String, required: true },
    days: { type: Number, required: true },
    total_price: { type: Number, required: true },
    status: { type: String, enum: ['accept', 'reject', 'pending', 'complete'], required: true },
    date: { type: Date, required: true },
    reject_reason:{ type: String, required: false },
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const ServiceOrderModel = mongoose.model('Service_Order', serviceOrderSchema);

module.exports = ServiceOrderModel;
