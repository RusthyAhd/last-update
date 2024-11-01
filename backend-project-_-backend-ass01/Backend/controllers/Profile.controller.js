const Profile = require('../models/Profile.model');
const AuthController = require('./AuthController')
const CustomResponse = require('../utils/custom.response');
const ToolOrderController = require('../controllers/ToolOrder.controller');
const ServiceOrderController = require('../controllers/ServiceOrder.controller');

// Controller method to handle creating or updating a user profile
exports.createOrUpdateProfile = async (req, res) => {

    try {
        // Destructure fields from request body
        const { fullName, phoneNumber, email, birthday, gender,address,location, profilePhoto } = req.body;

        // Validate input
        if (!fullName || !phoneNumber || !email || !birthday || !gender || !address ||!location ) {
            return res.status(400).send(
                new CustomResponse(
                    404,
                    'All fields are required'
                )
            )
        }

        // Create or update user profile directly inside the controller
        const profile = await Profile.findOneAndUpdate(
            { phoneNumber: phoneNumber }, // Use email to find and update profile
            { fullName, email, birthday, gender,address,location, profilePhoto  },
            { new: true, upsert: true } // Create if not found
        );

        let token = await AuthController.generateJwtToken(profile);

        // Respond with a success message
        // res.status(200).json({ status: true, success: 'Profile updated successfully', data: profile });
        return res.status(200).send(
            new CustomResponse(
                200,
                'Profile updated successfully',
                {
                    token:token,
                    user:profile
                }
            )
        )

    } catch (error) {
        console.error('Error getting orders :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to update profile!',
                {
                    error: error.message
                }
            )
        )
    }

};


exports.getAllOrdersByUserId = async (req, res, next) => {

    const { user_id } = req.query;

    try {

        if (!user_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'User id is required!'
                )
            )
        }

        //get all tool orders
        let tool_orders = await ToolOrderController.getToolOrders(user_id);

        //get all service orders
        let service_orders = await ServiceOrderController.getServiceOrders(user_id);

        let order_list = [];

        tool_orders.map(val => {
            order_list.push(val)
        })

        service_orders.map(val => {
            order_list.push(val)
        })

        return res.status(200).send(
            new CustomResponse(
                200,
                'User orders found successfully.',
                order_list
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