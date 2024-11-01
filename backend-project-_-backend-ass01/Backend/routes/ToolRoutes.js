const express = require('express'); // Import express package
const ToolController = require('../controllers/Tool.controller');
const {verifyToken} = require("../middleware/authMiddleware");

const router = express.Router();

router.post('/new/:shop_email', verifyToken, ToolController.addNewTool)

router.get('/get/all/:shop_id', verifyToken, ToolController.getAllTools)

router.get('/get/:tool_id', verifyToken, ToolController.getAllToolById)

router.put('/update/:tool_id', verifyToken, ToolController.updateTool)

router.delete('/delete/:tool_id', verifyToken, ToolController.deleteTool)

module.exports = router;
