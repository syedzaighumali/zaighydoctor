const admin = require('firebase-admin');
const { sendSuccess, sendError } = require('../utils/response');

exports.getHospitals = async (req, res) => {
    try {
        const { city } = req.query;
        const lang = req.query.lang || 'en';
        const db = admin.firestore();

        let query = db.collection('hospitals');
        if (city) {
            // Firestore queries are case-sensitive and exact. 
            // For a better search, we might need a search service or manual filtering.
            // For now, let's try exact matching or fetch all and filter.
            query = query.where('city', '==', city);
        }

        const snapshot = await query.get();
        const hospitals = snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                ...data,
                name: (lang === 'ur' && data.name_ur) ? data.name_ur : data.name,
                city: (lang === 'ur' && data.city_ur) ? data.city_ur : data.city,
            };
        });

        sendSuccess(res, hospitals);
    } catch (err) {
        console.error(err);
        sendError(res, 'Internal Server Error', 500);
    }
};
