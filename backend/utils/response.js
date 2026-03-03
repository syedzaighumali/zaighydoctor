const DISCLAIMER = "This platform provides general health guidance only. Consult a licensed doctor before taking any medication.";

exports.sendSuccess = (res, data, statusCode = 200) => {
    return res.status(statusCode).json({
        success: true,
        data,
        disclaimer: DISCLAIMER
    });
};

exports.sendError = (res, message, statusCode = 400) => {
    return res.status(statusCode).json({
        success: false,
        error: message,
        disclaimer: DISCLAIMER
    });
};
