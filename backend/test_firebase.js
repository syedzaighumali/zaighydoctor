const admin = require('firebase-admin');
const fs = require('fs');

const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function test() {
    try {
        console.log('Testing Firestore Connection...');
        const testRef = db.collection('test').doc('ping');
        await testRef.set({ time: new Date().toISOString() });
        const doc = await testRef.get();
        console.log('Success! Data written and read:', doc.data());
        process.exit(0);
    } catch (err) {
        console.error('Firestore Test Failed:', err.message);
        process.exit(1);
    }
}

test();
