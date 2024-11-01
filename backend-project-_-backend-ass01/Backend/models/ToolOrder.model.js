const mongoose = require('mongoose');

// Define the Owner schema
const toolOrderSchema = new mongoose.Schema({
    order_id: { type: String, required: true },
    tool_id: { type: String, required: true },
    shop_id: { type: String, required: true },
    customer_id: { type: String, required: true },
    customer_name: { type: String, required: true },
    customer_address: { type: String, required: true },
    customer_location: { type: String, required: true },
    customer_number: { type: String, required: true },
    title: { type: String, required: true },
    qty: { type: Number, required: true },
    days: { type: Number, required: true },
    total_price: { type: Number, required: true },
    status: { type: String, enum: ['accept', 'reject', 'pending', 'complete'], required: true },
    date: { type: Date, required: true },
    reject_reason:{ type: String, required: false },
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const ToolOrderModel = mongoose.model('Tool_Order', toolOrderSchema);

module.exports = ToolOrderModel;
