const CustomResponse = require('../utils/custom.response');
const ServiceProvider = require('../models/ServiceProvider.model')
const ServiceModel = require('../models/Service.model')

exports.addNewService = async (req, res, next) => {

    try {

        const { name, description, service_category, service, pic, price, availability, available_days, available_hours, condition, location_long, location_lat } = req.body;
        const { service_provider_id } = req.params;

        if(!name || !description || !service_category || !service || ! price ||
            !availability || !available_days || !available_hours || !condition || !location_lat || !location_long){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required'
                )
            )
        }

        let provider = await ServiceProvider.findById(service_provider_id);

        if (!provider){
            return res.status(400).send(
                new CustomResponse(
                    404,
                    "Can't find service provider!"
                )
            )
        }

        const service_id = 'SV-'+Date.now();

        let serviceModel = new ServiceModel({
            service_id,
            service,
            name,
            description,
            service_provider_id,
            service_category,
            pic: pic || provider.pic,
            price,
            availability,
            available_days,
            available_hours,
            condition,
            location_long,
            location_lat
        });

        let new_service = await serviceModel.save();


        return res.status(200).send(
            new CustomResponse(
                200,
                'Add new service successfully!',
                new_service
            )
        )


    }catch (error){
        console.error('Error add service :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to add service!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.deleteService = async (req, res, next) => {

    try {

        const { service_id } = req.params;

        let service = await ServiceModel.findOne({service_id});

        if (!service){
            return res.status(400).send(
                new CustomResponse(
                    404,
                    "Can't find service!"
                )
            )
        }

        await ServiceModel.deleteOne({service_id});

        return res.status(200).send(
            new CustomResponse(
                200,
                'Service deleted successfully!'
            )
        )

    }catch (error){
        console.error('Error delete service :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to delete service!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.updateService = async (req, res, next) => {

    const { service_id } = req.params;
    const {
        service,
        name,
        description,
        service_category,
        pic,
        price,
        availability,
        available_days,
        available_hours,
        condition,
        location_long,
        location_lat
    } = req.body;

    try {

        const existingService = await ServiceModel.findOne({ service_id });

        if (!existingService) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Service with ID ${service_id} not found`
                )
            )
        }


        const updatedService = await ServiceModel.findOneAndUpdate(
            { service_id },
            {
                service: service || existingService.service,
                name: name || existingService.name,
                description: description || existingService.description,
                service_provider_id:  existingService.service_provider_id,
                service_category: service_category || existingService.service_category,
                pic: pic || existingService.pic,
                price: price || existingService.price,
                availability: availability || existingService.availability,
                available_days: available_days || existingService.available_days,
                available_hours: available_hours || existingService.available_hours,
                condition: condition || existingService.condition,
                location_long: location_long || existingService.location_long,
                location_lat: location_lat || existingService.location_lat
            },
            { new: true } // Return the updated document
        );

        return res.status(200).send(
            new CustomResponse(
                200,
                'Service updated successfully',
                updatedService
            )
        )


    } catch (error) {
        console.error('Error updating service:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to updating service!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getAllServicesByServiceProviderId = async (req, res, next) => {

    const { service_provider_id } = req.params;

    try {

        const services = await ServiceModel.find({ service_provider_id });

        return res.status(200).send(
            new CustomResponse(
                200,
                `Services found for service provider ID ${service_provider_id}`,
                services
            )
        )
    } catch (error) {
        console.error('Error fetching services:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetching services!',
                {
                    error: error.message
                }
            )
        )
    }
}

exports.getServiceById = async (req, res, next) => {

    const { service_id } = req.params;

    try {

        const service = await ServiceModel.findOne({ service_id });

        if (!service) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Service with ID ${service_id} not found!`
                )
            )
        }

        return res.status(200).send(
            new CustomResponse(
                200,
                `Service found for ID ${service_id}`,
                service
            )
        )

    } catch (error) {
        console.error('Error fetching service:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetching service!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getAllServicesByLocationAndCategory = async (req, res, next) => {

    const { location_long, location_lat, service_category } = req.body;

    if (!location_long || !location_lat || !service_category) {
        return res.status(400).send(
            new CustomResponse(
                400,
                'Please provide location_long, location_lat, and service_category',
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

        // query to find services by location range and service_category
        const services = await ServiceModel.find({
            service_category: service_category,
            location_long: { $gte: long - range, $lte: long + range },
            location_lat: { $gte: lat - range, $lte: lat + range }
        });


        return res.status(200).send(
            new CustomResponse(
                200,
                `Services found successfully`,
                services
            )
        )

    } catch (error) {
        console.error('Error fetching services:', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to fetching services!',
                {
                    error: error.message
                }
            )
        )
    }

}