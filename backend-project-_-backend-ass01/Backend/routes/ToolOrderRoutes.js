const express = require('express'); // Import express package
const ToolOrderController = require('../controllers/ToolOrder.controller');
const {verifyToken} = require("../middleware/authMiddleware");

const router = express.Router();

router.post('/new', verifyToken, ToolOrderController.addNewOrder)

router.put('/change/status', verifyToken, ToolOrderController.changeStatus)

router.get('/get/all/status', verifyToken, ToolOrderController.findOrderByStatusAndShopId)

router.get('/get/user/all', verifyToken, ToolOrderController.getAllUserOrdersById)

router.post('/get/all/date/order', verifyToken, ToolOrderController.findOrdersDateOrId)

router.get('/get/all/:shop_id', verifyToken, ToolOrderController.getAllOrdersByShopId)

module.exports = router;
