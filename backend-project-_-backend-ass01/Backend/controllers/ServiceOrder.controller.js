const CustomResponse = require('../utils/custom.response');
const ServiceProviderModel = require('../models/serviceProvider.model');
const ServiceModel = require('../models/Service.model')
const ServiceOrderModel = require('../models/ServiceOrder.model')
const ToolOrderModel = require("../models/ToolOrder.model");
const OTPGateWay = require("../utils/OTPGateway");

exports.addNewOrder = async (req, res, next) => {

    const { service_id, description, days, status, date, reject_reason, customer_address } = req.body;

    if ( !service_id || !description || !days || !status || !date) {
        return res.status(400).send(
            new CustomResponse(
                400,
                'All required fields must be provided.'
            )
        );
    }

    try {

        let service = await ServiceModel.findOne({service_id});

        if (!service){
            return res.status(404).send(
                new CustomResponse(
                    404,
                    'Can not find service! '
                )
            );
        }

        console.log(req.tokenData.user)
        console.log(req.tokenData.user.location)

        if (!req.tokenData.user.fullName || !req.tokenData.user.address || !req.tokenData.user.phoneNumber || !req.tokenData.user.location){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Can not find required details! Please update your profile details first and try again.'
                )
            );
        }

        const newServiceOrder = new ServiceOrderModel({
            order_id: 'SO-'+Date.now(),
            service_id,
            provider_id:service.service_provider_id,
            customer_id:req.tokenData.user._id,
            customer_name:req.tokenData.user.fullName,
            customer_address:customer_address || req.tokenData.user.address,
            customer_location: req.tokenData.user.location,
            customer_number:req.tokenData.user.phoneNumber,
            description,
            days,
            total_price: service.price * days,
            status,
            date,
            reject_reason // Optional field
        });


        const savedServiceOrder = await newServiceOrder.save();

        return res.status(200).send(
            new CustomResponse(
                200,
                'Service order placed successfully',
                savedServiceOrder
            )
        )
    } catch (error) {
        console.error('Error placing service order:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'An error occurred while placing the service order',
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

        let order = await ServiceOrderModel.findOne({order_id});

        if (!order){
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Order with ID ${order_id} not found!`
                )
            )
        }

        await ServiceOrderModel.updateOne(
            {order_id},
            {
                status:status,
                reject_reason: reason || ''
            }
        );

        //⚠️ sending sms alert

        const message= `Dear customer ((${order.customer_name})), Your order (ID : ${order_id}) ${order.description} is ${status} by ${order.provider_id}`

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

exports.getAllOrdersByProviderId = async (req, res, next) => {

    try {
        const { provider_id } = req.params;

        if(!provider_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop id is required!'
                )
            );
        }

        let list = await ServiceOrderModel.find({provider_id});

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

exports.findOrderByStatusAndProviderId = async (req, res, next) => {

    try {

        const { provider_id, status } = req.query;

        if(!provider_id || !status){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop is and status are required!'
                )
            );
        }

        let list =
            await ServiceOrderModel.find({provider_id:provider_id, status:status });

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

        if (!date && !order_id) {
            return res.status(400).send(
                new CustomResponse(
                    404,
                    'Please provide either date or order_id to search orders'
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
        const orders = await ServiceOrderModel.find(query);

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

        let orders = await this.getServiceOrders(user_id);

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

exports.getServiceOrders = async (id) => {

    return await ServiceOrderModel.find({customer_id:id})

}