const admin = require('firebase-admin');
const { sendError } = require('../utils/response');

module.exports = async (req, res, next) => {
    const token = req.header('Authorization')?.split(' ')[1];
    if (!token) return sendError(res, 'Access Denied. No token provided.', 401);

    try {
        const decoded = await admin.auth().verifyIdToken(token);
        const db = admin.firestore();

        // Use Firestore instead of MongoDB
        const userRef = db.collection('users').doc(decoded.uid);
        const doc = await userRef.get();

        if (!doc.exists) {
            // Create user profile if it doesn't exist
            await userRef.set({
                firebase_uid: decoded.uid,
                name: decoded.name || 'User',
                email: decoded.email || '',
                created_at: admin.firestore.FieldValue.serverTimestamp()
            });
        }

        req.user = {
            _id: decoded.uid,
            firebase_uid: decoded.uid,
            name: doc.exists ? doc.data().name : (decoded.name || 'User')
        };
        next();
    } catch (ex) {
        console.error('Auth Middleware Error Detail:', ex);
        sendError(res, ex.message || 'Invalid or expired token.', 401);
    }
};
