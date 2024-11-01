const express = require('express'); // Import express package
const ServiceController = require('../controllers/Service.controller');
const {verifyToken} = require("../middleware/authMiddleware");

const router = express.Router();

router.post('/get/all/cl', verifyToken, ServiceController.getAllServicesByLocationAndCategory)

router.post('/new/:service_provider_id', verifyToken, ServiceController.addNewService)

router.get('/get/all/:service_provider_id', verifyToken, ServiceController.getAllServicesByServiceProviderId)

router.get('/get/:service_id', verifyToken, ServiceController.getServiceById)

router.put('/update/:service_id', verifyToken, ServiceController.updateService)

router.delete('/delete/:service_id', verifyToken, ServiceController.deleteService)

module.exports = router;
