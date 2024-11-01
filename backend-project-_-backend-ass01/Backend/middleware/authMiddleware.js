const {verify} = require("jsonwebtoken");
const CustomResponse = require('../utils/custom.response');

exports.verifyToken = async (req,res,next) => {

    try {

        let authorizationToken = req.headers.authorization;

        if (!authorizationToken){
            return res.status(401).json(
                new CustomResponse(404, "Token not found!")
            )
        }

        // let token_data = jwt.verify(authorizationToken, process.env.SECRET as Secret);
        // res.tokenData = token_data;
        req.tokenData = verify(authorizationToken, process.env.JWT_SECRET);
        next();

    }catch (e){
        return res.status(500).send(
            new CustomResponse(
                404,
                "Invalid Token"
            )
        )

    }

}