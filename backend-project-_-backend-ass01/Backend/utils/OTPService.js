const otpGenerator = require('otp-generator')
const CustomResponse = require("./custom.response");
const process = require('process')
const bcrypt = require('bcrypt')
const OTPModel = require('../models/Otp.model');
const Profile = require("../models/Profile.model");

exports.sentOTP = async (req,res,next) => {
    try {

        //check phone number is existing
        if (!req.params.phoneNumber){
            return res.status(404).send(
                new CustomResponse(404,`Phone number not found!`)
            )
        }

        //generate new otp number
        let otp = otpGenerator.generate(6,{
            digits:true,
            upperCaseAlphabets:false,
            lowerCaseAlphabets:false,
            specialChars:false
        });


        //encoded otp
        let encodedOtp = await bcrypt.hash(otp,10,);


        //save otp with phoneNumber in db

        //update if phone number exists or create new
        await OTPModel.findOneAndUpdate(
            { phoneNumber: req.params.phoneNumber },
            { otp: encodedOtp },
            { new: true, upsert: true }
        );

        if (process.env.OTP_SMS_GATWAY==='ON'){
            //otp sending logic

            const accountSid = process.env.PHONE_VERIFICATION_SID;
            const authToken = process.env.PHONE_VERIFICATION_AUTH_TOKEN;
            const client = require('twilio')(accountSid, authToken);

            // client.verify.v2.services("VA45c5a6bf8686d26dd9b843811a92f810")
            //     .verifications
            //     .create({to: '+94755354023', channel: 'sms'})
            //     .then(verification => console.log(verification.sid))
            //     .catch(error => {
            //         console.log(error)
            //         return res.status(500).send(
            //             new CustomResponse(500,`Error ${error}`)
            //         )
            //     })

            await client.messages
                .create({
                    body: `Welcome, your OTP is ${otp}`,
                    from: process.env.TWILIO_PHONE_NUMBER || '+13193132610',
                    to: '+94755354023' // The recipient's phone number if you get paid one replace req.params.phoneNumber
                })
                .then(message => {
                    console.log(message.sid);
                })
                .catch(error => {
                    console.error(error);
                    return res.status(500).send(
                        new CustomResponse(500, `OTP sending Error: ${error.message}`)
                    );
                });


        }else {
            //print in console
            console.log("📌 OTP ",otp)
        }


        //sent success response
        res.status(200).send(
            new CustomResponse(200,`OTP SEND SUCCESSFULLY`)
        )

    }catch (error){
        console.log(error)
        return res.status(500).send(
            new CustomResponse(500,`Error ${error}`)
        )
    }
}

