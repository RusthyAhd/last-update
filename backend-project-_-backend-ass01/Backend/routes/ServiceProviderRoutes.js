const express = require('express'); // Import express
const ServiceProviderController = require('../controllers/ServiceProvider.controller');
const {verifyToken} = require("../middleware/authMiddleware"); // Import the controller

const router = express.Router(); // Create a new router

// Define the route for service provider registration
router.post('/registration', ServiceProviderController.serviceregister);

router.post('/service-providers/category/location', verifyToken, ServiceProviderController.getServiceProviders);

router.get('/find', verifyToken, ServiceProviderController.findServiceProvideByEmail)

router.post('/login/provider', verifyToken, ServiceProviderController.login)

router.put('/update/provider', verifyToken, ServiceProviderController.updateProvider)

module.exports = router;
