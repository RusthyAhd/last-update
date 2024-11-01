const ShopOwnerModel = require('../models/Owner.model'); // Import the Owner model
const bcrypt = require('bcrypt');
const CustomResponse = require("../utils/custom.response");

// Controller method to handle the registration
exports.register = async (req, res) => {
    try {
        // Destructure fields from request body
        const { name, shop_name, phone, address, location_long, location_lat, email, category, password, confirmPassword, pic } = req.body;
        
        // Validate input
        if (!name || !shop_name || !phone || !address || !location_long ||
            !location_lat || !email || !category || !password || !confirmPassword ) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required'
                )
            )
        }

        // Check if passwords match
        if (password !== confirmPassword) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Passwords do not match'
                )
            )
        }

        // Hash the password before saving
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create new owner directly inside the controller
        const newOwner = new ShopOwnerModel({
            name,
            shop_name,
            phone,
            address,
            location_long,
            location_lat,
            email,
            category,
            password: hashedPassword, // Store the hashed password
            pic
        });

        // Save to the database
        const savedOwner = await newOwner.save();
        
        // Respond with a success message
        res.status(200).send(
            new CustomResponse(
                200,
                `Shop owner registered successfully`,
                savedOwner
            )
        )
    } catch (error) {
        console.error(error);
        return res.status(500).send(
            new CustomResponse(
                500,
                'Registration failed. Try again later.'
            )
        )
    }
};

exports.getShopsByCategoryAndLocation = async (req, res, next) => {

    const { category, location_long, location_lat } = req.body;

    // Check if both category and location are provided
    if (!category || !location_long || !location_lat) {
        return res.status(400).send(
            new CustomResponse(
                400,
                'Please provide both category and location'
            )
        )
    }

    try {

        // parse location_long and location_lat into numbers
        const long = parseFloat(location_long);
        const lat = parseFloat(location_lat);

        // (You can adjust this for your use case)
        // Latitude/Longitude range within which to search (approximately 11km)
        const range = 0.1;

        // Find all shop owners by category and location
        const shopOwners =
            await ShopOwnerModel.find({
                category,
                location_long: { $gte: long - range, $lte: long + range },
                location_lat: { $gte: lat - range, $lte: lat + range }
            });


        // Return the list of shop owners
        res.status(200).send(
            new CustomResponse(
                200,
                `Shop owners for category: ${category} and location long: ${location_long} and location_lang, location lat:${location_lat}`,
                shopOwners
            )
        )

    } catch (error) {

        console.error('Error fetching shop owners:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetch shop owners',
                {
                    message: 'An error occurred while fetching shop owners',
                    error: error.message
                }
            )
        )
    }

}

exports.updateShopDetails = async (req, res, next) => {

    const { id } = req.params;

    const { email, phone, name, shop_name, address, location_long, location_lat, category, pic } = req.body;

    try {

        // Validate input
        if (!id) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'ID is required (_id)!'
                )
            )
        }

        // Find the shop owner by _id
        const owner = await ShopOwnerModel.findById(id);

        if (!owner) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    'Shop owner not found! Please check the it and try again'
                )
            )
        }

        // Update the shop owner details
        const updatedOwner = await ShopOwnerModel.findByIdAndUpdate(
            id,
            {
                name: name || owner.name,
                shop_name: shop_name || owner.shop_name,
                phone: phone || owner.phone,
                address: address || owner.address,
                location_long: location_long || owner.location_long,
                location_lat: location_lat || owner.location_lat,
                email: email || owner.email,
                category: category || owner.category,
                pic: pic || owner.pic
                // password: updatedPassword,
            },
            { new: true } // Return the updated document
        );


        // Return the found shop owner
        res.status(200).send(
            new CustomResponse(
                200,
                'Shop owner updated successfully.',
                updatedOwner
            )
        )

    } catch (error) {
        console.error('Error update shop owner:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to update shop owner',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.login = async (req, res, next) => {

    try {

        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required'
                )
            )
        }

        // Find the shop owner by _id
        const owner = await ShopOwnerModel.findOne({email});

        if (!owner){
            return res.status(500).send(
                new CustomResponse(
                    500,
                    "Invalid email! Can't find shop ower."
                )
            )
        }


        if (!await bcrypt.compare(password,owner.password)){
            return res.status(401).send(
                new CustomResponse(
                    401,
                    "Invalid Password!"
                )
            )
        }

        delete owner.password;

        // Return the found shop owner
        res.status(200).send(
            new CustomResponse(
                200,
                'Shop owner login successfully!',
                {
                    user:owner
                }
            )
        )

    }catch (error) {
        console.error('Error shop owner login :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to login shop owner',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.addNewTool = async (req, res, next) => {

    try {

        const { tool_id, pic, qty, item_price, availability, available_days, available_hours } = req.body;
        const { shop_email } = req.params;

    }catch (error) {
        console.error('Error add tool :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to add tool!',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.findOwnerByEmail = async (req,res) => {

    try {

        const email = req.query.email;

        if (!email){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Email not found!'
                )
            )
        }

        let owner = await ShopOwnerModel.findOne({email});

        if (!owner){
            return res.status(400).send(
                new CustomResponse(
                    404,
                    'Shop owner not found'
                )
            )
        }

        owner.password='';

        res.status(200).send(
            new CustomResponse(
                200,
                'Shop owner found',
                owner
            )
        )

    }catch (error){
        console.error(error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetch shop owner!',
                {
                    error: error.message
                }
            )
        )
    }

}

