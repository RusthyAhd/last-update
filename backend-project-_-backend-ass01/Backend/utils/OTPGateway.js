const process = require("process");
const CustomResponse = require("./custom.response");


exports.sentSMS = async (message,phoneNumber) => {

    console.log(message)
    console.log(phoneNumber)

    if (process.env.OTP_SMS_GATWAY==='ON'){

        const accountSid = process.env.PHONE_VERIFICATION_SID;
        const authToken = process.env.PHONE_VERIFICATION_AUTH_TOKEN;


        const client = require('twilio')(accountSid, authToken);

        await client.messages
            .create({
                from: process.env.TWILIO_PHONE_NUMBER || '+13193132610',
                to: '+94755354023', // replace phoneNumber here
                body: message
            })
            .then(message => console.log(message.sid))
            .catch((error => {
                console.log(error)
                throw Error("SMS gateway error, but data saved in db! ⚠️ "+error.message)
            }))
    }

}