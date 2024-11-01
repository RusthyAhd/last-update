const express = require('express');
const ServiceOrderController = require('../controllers/ServiceOrder.controller');
const {verifyToken} = require("../middleware/authMiddleware");
const ToolOrderController = require("../controllers/ToolOrder.controller");

const router = express.Router();

router.post('/new', verifyToken, ServiceOrderController.addNewOrder)

router.put('/change/status', verifyToken, ServiceOrderController.changeStatus)

router.get('/get/all/status', verifyToken, ServiceOrderController.findOrderByStatusAndProviderId)

router.get('/get/user/all', verifyToken, ServiceOrderController.getAllUserOrdersById)

router.post('/get/all/date/order', verifyToken, ServiceOrderController.findOrdersDateOrId)

router.get('/get/all/:provider_id', verifyToken, ServiceOrderController.getAllOrdersByProviderId)

module.exports = router;
