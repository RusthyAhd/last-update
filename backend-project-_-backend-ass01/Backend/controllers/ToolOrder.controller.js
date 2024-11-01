const CustomResponse = require("../utils/custom.response");
const ToolModel = require('../models/Tool.model')
const ToolOrderModel = require('../models/ToolOrder.model')
const ShopOwner = require('../models/Owner.model')
const OTPGateWay = require("../utils/OTPGateway");

exports.addNewOrder = async (req, res, next) => {

    try {

        const { tool_id, shop_id, title, qty, days, status, date, customer_address } = req.body;

        if (!tool_id || !shop_id || !title || !qty || !days || !status || !date) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required!'
                )
            );
        }

        // 1: Verify if the tool exists by tool_id
        const tool = await ToolModel.findOne({ tool_id });

        if (!tool) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Tool with ID ${tool_id} not found`
                )
            )
        }

        //generate new tool-order id
        const order_id = 'OT-'+Date.now();

        const total_price = qty * (days * tool.item_price);

        if (!req.tokenData.user.fullName || !req.tokenData.user.address || !req.tokenData.user.phoneNumber || !req.tokenData.user.location){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Can not find required details! Please update your profile details first and try again.'
                )
            );
        }

        let shop_details = await ShopOwner.findById(shop_id);

        if (!shop_details){
            return res.status(404).send(
                new CustomResponse(
                    404,
                    'Can not find shop! '
                )
            );
        }


        // 2: Create the new order instance
        const newToolOrder = new ToolOrderModel({
            order_id,
            tool_id,
            shop_id,
            customer_id:req.tokenData.user._id,
            customer_name:req.tokenData.user.fullName,
            customer_address:customer_address || req.tokenData.user.address,
            customer_location:req.tokenData.user.location,
            customer_number:req.tokenData.user.phoneNumber,
            title,
            qty,
            days,
            total_price,
            status: status || 'pending',// Default status is 'pending'
            date
        });

        await newToolOrder.save();

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Order added successfully',
            )
        )


    }catch (error){
        console.error('Error get all tool :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get tools!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.changeStatus = async (req, res, next) => {

    try {

        const { order_id, status, reason } = req.body;

        if(!order_id || !status){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required!'
                )
            );
        }

        if (status === 'reject' && !reason) {
            return res.status(400).send(
                new CustomResponse(400, 'Reason is required to reject order!')
            );
        }

        let order = await ToolOrderModel.findOne({order_id});

        if (!order){
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Order with ID ${order_id} not found!`
                )
            )
        }

        await ToolOrderModel.updateOne(
            {order_id},
            {
                status:status,
                reject_reason: reason || ""
            }
        );

        //⚠️ sending sms alert

        const message= `Dear customer (${order.customer_name}), Your order (ID : ${order_id}) ${order.title} is ${status} by ${order.shop_id}`

        await OTPGateWay.sentSMS(message, order.customer_number)

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Order status update successfully',
            )
        )

    }catch (error){
        console.error('Error change order status :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to change order status!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getAllOrdersByShopId = async (req, res, next) => {

    try {
        const { shop_id } = req.params;

        if(!shop_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop id is required!'
                )
            );
        }

        let list = await ToolOrderModel.find({shop_id});

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Orders find successfully',
                list
            )
        )


    }catch (error){
        console.error('Error getting order :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get order!',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.findOrderByStatusAndShopId = async (req, res, next) => {

    try {

        const { shop_id, status } = req.query;

        if(!shop_id || !status){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop is and status are required!'
                )
            );
        }

        console.log(shop_id)
        console.log(status)

        let list = await ToolOrderModel.find({shop_id:shop_id, status:status });

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Orders find successfully',
                list
            )
        )

    }catch (error) {
        console.error('Error getting order :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get order!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.findOrdersDateOrId = async (req, res, next) => {

    const { date, order_id } = req.body;

    try {

        // Validate that at least one of date or order_id is provided
        if (!date && !order_id) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Please provide either date or order_id to search orders',
                )
            )
        }

        // Construct the query based on the parameters provided
        let query = {};

        if (order_id) {
            // Search by order_id if provided
            query.order_id = order_id;
        }

        if (date) {
            // Convert to a Date object
            const searchDate = new Date(date);
            // Search by date (ensure only the date part is compared)
            query.date = {
                $gte: new Date(searchDate.setHours(00, 00, 00)), // Start of the day
                $lt: new Date(searchDate.setHours(23, 59, 59))   // End of the day
            };
        }

        // Find orders based on the constructed query
        const orders = await ToolOrderModel.find(query);

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Orders find successfully',
                orders
            )
        )

    }catch (error) {
        console.error('Error getting order :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get order!',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.getAllUserOrdersById = async (req, res, next) => {

    try {

        const { user_id } = req.query;

        if (!user_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'User id is required!'
                )
            )
        }

        let orders = await this.getToolOrders(user_id);

        return res.status(200).send(
            new CustomResponse(
                200,
                'User orders found successfully.',
                orders
            )
        )

    }catch (error){
        console.error('Error getting orders :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get orders!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getToolOrders = async (id) => {

    return await ToolOrderModel.find({customer_id:id});

}