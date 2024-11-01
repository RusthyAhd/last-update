const mongoose = require('mongoose');

// Define the Owner schema
const toolSchema = new mongoose.Schema({
    tool_id: { type: String, required: true },
    shop_id: { type: String, required: true },
    title: { type: String, required: true },
    pic: { type: String, required: true },
    qty: { type: Number, required: true },
    item_price: { type: Number, required: true },
    availability: { type: String,enum: ['Available', 'Unavailable', 'Sold_out'], required: true },
    available_days: { type: [String], required: true },
    available_hours: { type: String, required: true },
}, { timestamps: true });

// Check if the model is already compiled to prevent OverwriteModelError
const ToolModel = mongoose.model('Tools', toolSchema);

module.exports = ToolModel;
