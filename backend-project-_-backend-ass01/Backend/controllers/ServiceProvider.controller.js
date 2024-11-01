const ServiceProviderModel = require('../models/serviceProvider.model'); // Import the model
const bcrypt = require('bcrypt');
const CustomResponse = require('../utils/custom.response');

// Register Service Provider
exports.serviceregister = async (req, res, next) => {
    try {
        const { name, service_title, phone, address, location_long, location_lat , email, category, description, password, pic } = req.body;

        // Validate required fields
        if (!name || !service_title || !phone || !address || !location_long || !location_lat || !email || !category || !description || !password) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required'
                )
            )
        }

        // Check for existing phone or email
        const existingProvider = await ServiceProviderModel.findOne({ $or: [{ phone }, { email }] });
        if (existingProvider) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Phone or email already exists'
                )
            )
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new service provider entry
        const newServiceProvider = new ServiceProviderModel({
            name,
            service_title,
            phone,
            address,
            location_long,
            location_lat,
            email,
            category,
            description,
            password: hashedPassword, // Store hashed password
            pic
        });

        // Save to the database
        const savedServiceProvider = await newServiceProvider.save();

        // Send response back
        res.status(200).send(
            new CustomResponse(
                200,
                `Service provider registered successfully`,
                savedServiceProvider
            )
        )
    } catch (error) {
        console.error(error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Registration failed. Try again later.',
                {
                    error: error.message
                }
            )
        )
    }
};

// Get all Service Providers
exports.getServiceProviders = async (req, res, next) => {

    try {

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

        // Find all service providers with the specified category
        const serviceProviders = await ServiceProviderModel.find({ category , location_long, location_lat });

        if (serviceProviders.length > 0) {
            serviceProviders.map(val => {
                val.password=''
            })
        }

        // Send the list of service providers
        res.status(200).send(
            new CustomResponse(
                200,
                `Service providers for category: ${category} 
                and location lang: ${location_long} and location_lang, location lat:${location_lat}`,
                serviceProviders
            )
        )

    } catch (error) {
        console.error(error);
        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetch service providers',
                {
                    error: error.message
                }
            )
        )
    }

};

exports.findServiceProvideByEmail = async (req, res, next) => {

    // Get email from query parameters
    const email = req.query.email;

    try {

        if (!email){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Email not found!'
                )
            )
        }

        const serviceProvider =
            await ServiceProviderModel.findOne({ email });

        if (serviceProvider) {

            serviceProvider.password='';

            // Send the service provider
            res.status(200).send(
                new CustomResponse(
                    200,
                    `Service providers found successfully.`,
                    serviceProvider
                )
            )
        } else {
            res.status(400).send(
                new CustomResponse(
                    404,
                    'Service provider not found'
                )
            )
        }
    } catch (error) {
        console.error(error);
        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetch service provider!',
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
        const provider = await ServiceProviderModel.findOne({email});

        if (!provider){
            return res.status(500).send(
                new CustomResponse(
                    500,
                    "Invalid email! Can't find shop ower."
                )
            )
        }


        if (!await bcrypt.compare(password,provider.password)){
            return res.status(401).send(
                new CustomResponse(
                    401,
                    "Invalid Password!"
                )
            )
        }

        provider.password='';
        delete provider.password;

        // Return the found shop owner
        res.status(200).send(
            new CustomResponse(
                200,
                'Service provider login successfully!',
                {
                    user:provider
                }
            )
        )

    }catch (error) {
        console.error('Error service provider login :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to login service provider!',
                {
                    error: error.message
                }
            )
        )
    }
}

exports.updateProvider = async (req, res, next) => {

    const { previous_email, name, service_title, phone, address, location_long, location_lat, email, category, description, pic } = req.body;

    try {

        const existingProvider =
            await ServiceProviderModel.findOne({ email: previous_email });

        if (!existingProvider) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Service provider with email ${previous_email} not found`
                )
            )
        }

        const updatedProvider = await ServiceProviderModel.findOneAndUpdate(
            { email: previous_email },
            {
                name: name || existingProvider.name,
                service_title: service_title || existingProvider.service_title,
                phone: phone || existingProvider.phone,
                address: address || existingProvider.address,
                location_long: location_long || existingProvider.location_long,
                location_lat: location_lat || existingProvider.location_lat,
                email: email || existingProvider.email,  // New email can be updated if provided
                category: category || existingProvider.category,
                description: description || existingProvider.description,
                password:  existingProvider.password,
                pic: pic || existingProvider.pic
            },
            { new: true } // Return the updated document
        );

        updatedProvider.password=''
        delete updatedProvider.password;

        return res.status(200).send(
            new CustomResponse(
                200,
                'Service provider updated successfully',
                updatedProvider
            )
        )

    } catch (error) {
        console.error('Error updating service provider:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'An error occurred while updating the service provider!',
                {
                    error: error.message
                }
            )
        )
    }

}