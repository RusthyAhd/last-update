const CustomResponse = require("../utils/custom.response");
const ShopOwnerModel = require('../models/Owner.model'); // Import the Owner model
const ToolModel = require('../models/Tool.model')

exports.addNewTool = async (req, res, next) => {

    try {

        const { title, pic, qty, item_price, availability, available_days, available_hours } = req.body;
        const { shop_email } = req.params;

        if (!shop_email || !title || !pic || !qty || !item_price || !availability || !available_days || !available_hours || available_days.length === 0) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required'
                )
            )
        }

        // verify that the shop exists
        const shopOwner =
            await ShopOwnerModel.findOne({ email: shop_email });

        if (!shopOwner) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    'Shop owner not found! Please check the it and try again'
                )
            )
        }

        //generate new tool id
        const tool_id = 'Tool-'+Date.now();

        // create the new tool instance
        const newTool = new ToolModel({
            tool_id,
            shop_id:shopOwner._id,
            title,
            pic,
            qty,
            item_price,
            availability,
            available_days,
            available_hours,
        });

        // Step 3: Save the tool to the database
        const savedTool = await newTool.save();

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Tool added successfully',
                {
                    savedTool
                }
            )
        )

    }catch (error) {
        console.error('Error add tool :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to add tool!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getAllTools = async (req, res, next) => {

    try {

        const { shop_id } = req.params;

        if (!shop_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop owner email required!'
                )
            )
        }

        // Find all tools by shop_email
        const tools = await ToolModel.find({ shop_id });

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Tools found successfully',
                tools
            )
        )


    }catch (error) {
        console.error('Error get all tool :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get tools!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getAllToolById = async (req, res, next) => {

    try {

        const { tool_id } = req.params;

        if (!tool_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Tool id email required!'
                )
            )
        }

        // Find all tool by tool_id
        const tool = await ToolModel.find({ tool_id });

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Tool found successfully',
                tool
            )
        )

    }catch (error){
        console.error('Error get all tool :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get tool!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.updateTool = async (req, res, next) => {

    const { tool_id } = req.params;
    const { title, pic, qty, item_price, availability, available_days, available_hours } = req.body;

    try {
        if (!tool_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Tool id email required!'
                )
            )
        }

        // verify if the tool exists by tool_id
        const existingTool = await ToolModel.findOne({ tool_id });

        if (!existingTool) {
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Tool with ID ${tool_id} not found`
                )
            )
        }

        // update the tool details
        const updatedTool = await ToolModel.findOneAndUpdate(
            { tool_id },
            {
                title: title || existingTool.title,
                pic: pic || existingTool.pic,
                qty: qty || existingTool.qty,
                item_price: item_price || existingTool.item_price,
                availability: availability || existingTool.availability,
                available_days: available_days || existingTool.available_days,
                available_hours: available_hours || existingTool.available_hours
            },
            { new: true } // Return the updated document
        );

        // return success response with updated tool
        return res.status(200).send(
            new CustomResponse(
                200,
                `Tool with ID ${tool_id} updated successfully`,
                updatedTool
            )
        )

    } catch (error) {
        console.error('Error updating tool :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to update tool!',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.deleteTool = async (req, res, next) => {

    try {

        const { tool_id } = req.params;

        let service = await ToolModel.findOne({tool_id});

        if (!service){
            return res.status(400).send(
                new CustomResponse(
                    404,
                    "Can't find tool!"
                )
            )
        }

        await ToolModel.deleteOne({tool_id});

        return res.status(200).send(
            new CustomResponse(
                200,
                'Tool deleted successfully!'
            )
        )

    }catch (error){
        console.error('Error delete service :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to delete tool!',
                {
                    error: error.message
                }
            )
        )
    }

}