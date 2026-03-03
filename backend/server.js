require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cors = require('cors');
const admin = require('firebase-admin');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');

const { sendError } = require('./utils/response');
const authRoutes = require('./routes/auth');
const consultationRoutes = require('./routes/consultation');
const emergencyRoutes = require('./routes/emergency');

// Initialize Firebase Admin SDK
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log('Firebase Admin initialized with service account key.');
} else {
    admin.initializeApp({
        projectId: process.env.FIREBASE_PROJECT_ID
    });
    console.log('Firebase Admin initialized with default credentials/Project ID.');
}

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });
console.log('Firebase Firestore initialized with ignoreUndefinedProperties...');

const app = express();

// 1. Security Middlewares
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));

// Limit API requests
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    handler: (req, res) => {
        sendError(res, 'Too many requests from this IP, please try again after 15 minutes', 429);
    }
});
app.use(limiter);

// 2. Parsers
app.use(express.json());

// 3. Mount Routes
app.use('/api/auth', authRoutes);
app.use('/api/consultations', consultationRoutes);
app.use('/api/emergency', emergencyRoutes);

// General 404
app.use((req, res) => {
    sendError(res, 'Endpoint not found', 404);
});

// Global error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    sendError(res, 'Internal Server Error', err.status || 500);
});

// App Entry
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Sehat Guide Backend running cleanly on port ${PORT}`);
});
