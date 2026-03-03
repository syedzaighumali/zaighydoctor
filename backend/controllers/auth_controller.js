const admin = require('firebase-admin');
const { sendSuccess, sendError } = require('../utils/response');
const Joi = require('joi');

const profileUpdateSchema = Joi.object({
    name: Joi.string().min(2).max(50),
    age: Joi.number().min(12).max(120)
}).min(1);

exports.getProfile = async (req, res) => {
    try {
        const db = admin.firestore();
        const userDoc = await db.collection('users').doc(req.user._id).get();

        if (!userDoc.exists) return sendError(res, 'User not found.', 404);

        sendSuccess(res, { id: userDoc.id, ...userDoc.data() });
    } catch (err) {
        console.error(err);
        sendError(res, 'Internal Server Error', 500);
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { error } = profileUpdateSchema.validate(req.body);
        if (error) return sendError(res, error.details[0].message, 400);

        const db = admin.firestore();
        const userRef = db.collection('users').doc(req.user._id);

        await userRef.update({
            ...req.body,
            updated_at: admin.firestore.FieldValue.serverTimestamp()
        });

        const updatedDoc = await userRef.get();
        sendSuccess(res, { id: updatedDoc.id, ...updatedDoc.data() });
    } catch (err) {
        console.error(err);
        sendError(res, 'Internal Server Error', 500);
    }
};
