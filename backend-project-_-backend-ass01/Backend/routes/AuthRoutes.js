const express = require('express');
const AuthController = require('../controllers/AuthController');
const {sentOTP} = require("../utils/OTPService");

const router = express.Router();

// Update POST route for shop registration
router.get('/otp/:phoneNumber',sentOTP);

router.post('/otp/verify',AuthController.verifyOtp);

module.exports = router;
