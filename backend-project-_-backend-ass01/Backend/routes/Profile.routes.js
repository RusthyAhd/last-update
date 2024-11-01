const express = require('express');
const router = express.Router();
const {createOrUpdateProfile, getAllOrdersByUserId }= require('../controllers/Profile.controller');
const {verifyToken} = require("../middleware/authMiddleware");


router.post('/cu', verifyToken, createOrUpdateProfile);

router.get('/get/all/order', verifyToken, getAllOrdersByUserId)

module.exports = router;
