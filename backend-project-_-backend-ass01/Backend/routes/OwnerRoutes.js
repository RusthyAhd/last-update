const express = require('express'); // Import express package
const OwnerController = require('../controllers/Owner.Controller');
const {verifyToken} = require("../middleware/authMiddleware");
const ServiceProviderController = require("../controllers/ServiceProvider.controller"); // Import the controller

const router = express.Router();

// Update POST route for shop registration
router.post('/registration', OwnerController.register);

router.post('/get/all/category/location', verifyToken, OwnerController.getShopsByCategoryAndLocation);

router.put('/update/:id', verifyToken, OwnerController.updateShopDetails);

router.post('/login/owner', verifyToken, OwnerController.login);

router.get('/find', verifyToken, OwnerController.findOwnerByEmail)

module.exports = router;
