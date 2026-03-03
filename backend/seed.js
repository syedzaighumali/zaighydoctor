require('dotenv').config();
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

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
    console.log('Firebase Admin initialized with Project ID from .env');
}

const db = admin.firestore();

async function clearCollection(collectionPath) {
    console.log(`Clearing collection: ${collectionPath}...`);
    const snapshot = await db.collection(collectionPath).get();
    if (snapshot.size === 0) return;

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
    });
    await batch.commit();
}

async function seed() {
    try {
        console.log('--- START FINAL COMPREHENSIVE SEEDING ---');

        await clearCollection('categories');
        await clearCollection('symptoms');
        await clearCollection('medicines');
        await clearCollection('symptom_medicine_map');
        await clearCollection('hospitals');

        // 1. Categories
        const categories = [
            { name: 'Brain / Neuro', name_ur: 'دماغی اور اعصابی', description: 'Brain and nerves related issues', description_ur: 'دماغ اور اعصاب سے متعلق مسائل' },
            { name: 'Heart & BP', name_ur: 'دل اور بلڈ پریشر', description: 'Heart and Blood Pressure issues', description_ur: 'دل اور بلڈ پریشر کے مسائل' },
            { name: 'Lungs', name_ur: 'پھیپھڑے', description: 'Respiratory and lung issues', description_ur: 'پھیپھڑوں کے مسائل' },
            { name: 'Fever / Infections', name_ur: 'بخار اور انفیکشن', description: 'Fever and viral/bacterial infections', description_ur: 'بخار اور انفیکشن' },
            { name: 'Allergy', name_ur: 'الرجی', description: 'Allergic reactions and skin issues', description_ur: 'الرجی کے مسائل' },
            { name: 'Stomach / Digestive', name_ur: 'معدہ اور ہاضمہ', description: 'Digestive and stomach issues', description_ur: 'معدہ اور ہاضمہ' },
            { name: 'Bottom / Rectal', name_ur: 'نیچے والے حصے کے مسائل', description: 'Rectal and related issues', description_ur: 'بواسیر اور متعلقہ مسائل' },
            { name: 'Female Health', name_ur: 'خواتین کی صحت', description: 'Womens specific health issues', description_ur: 'خواتین کے مخصوص مسائل' }
        ];

        const catMap = {};
        for (const cat of categories) {
            const dr = await db.collection('categories').add(cat);
            catMap[cat.name] = dr.id;
        }

        // 2. Symptoms (Matching UI list exactly)
        const symptomList = [
            // Brain
            { name: 'Headache (Tension type)', category_id: catMap['Brain / Neuro'] },
            { name: 'Migraine', category_id: catMap['Brain / Neuro'] },
            { name: 'Sinusitis', category_id: catMap['Brain / Neuro'] },
            { name: 'Vertigo', category_id: catMap['Brain / Neuro'] },
            // Heart
            { name: 'High Blood Pressure (Hypertension)', category_id: catMap['Heart & BP'] },
            { name: 'Angina (Chest pain due to heart)', category_id: catMap['Heart & BP'] },
            { name: 'High Cholesterol', category_id: catMap['Heart & BP'] },
            { name: 'Heart Failure', category_id: catMap['Heart & BP'] },
            // Lungs
            { name: 'Asthma', category_id: catMap['Lungs'] },
            { name: 'Bronchitis', category_id: catMap['Lungs'] },
            { name: 'Pneumonia', category_id: catMap['Lungs'] },
            // Fever
            { name: 'Common Fever', category_id: catMap['Fever / Infections'] },
            { name: 'Typhoid', category_id: catMap['Fever / Infections'] },
            { name: 'Dengue (Supportive care only)', category_id: catMap['Fever / Infections'] },
            { name: 'Malaria', category_id: catMap['Fever / Infections'] },
            // Allergy
            { name: 'Allergic Rhinitis', category_id: catMap['Allergy'] },
            { name: 'Skin Allergy', category_id: catMap['Allergy'] },
            // Stomach
            { name: 'Acidity / GERD', category_id: catMap['Stomach / Digestive'] },
            { name: 'Gastritis', category_id: catMap['Stomach / Digestive'] },
            { name: 'Diarrhea', category_id: catMap['Stomach / Digestive'] },
            { name: 'Constipation', category_id: catMap['Stomach / Digestive'] },
            { name: 'Stomach Ulcer', category_id: catMap['Stomach / Digestive'] },
            { name: 'Food Poisoning', category_id: catMap['Stomach / Digestive'] },
            // Bottom
            { name: 'Piles (Hemorrhoids)', category_id: catMap['Bottom / Rectal'] },
            { name: 'Anal Fissure', category_id: catMap['Bottom / Rectal'] },
            { name: 'Anal Infection', category_id: catMap['Bottom / Rectal'] },
            // Female
            { name: 'Vaginal Yeast Infection', category_id: catMap['Female Health'] },
            { name: 'Bacterial Vaginosis', category_id: catMap['Female Health'] },
            { name: 'Urinary Tract Infection (UTI)', category_id: catMap['Female Health'] },
            { name: 'PCOS', category_id: catMap['Female Health'] },
            { name: 'Painful Periods (Dysmenorrhea)', category_id: catMap['Female Health'] }
        ];

        const sympDocMap = {};
        for (const s of symptomList) {
            const dr = await db.collection('symptoms').add(s);
            sympDocMap[s.name] = dr.id;
        }

        // 3. Medicines
        const medicinesData = [
            {
                name: 'Paracetamol 500mg', name_ur: 'پیراسیٹامول 500 ملی گرام',
                category_id: catMap['Brain / Neuro'],
                dosage: '1 tablet thrice daily.', dosage_ur: 'ایک گولی دن میں تین بار',
                description: 'Used for tension headaches and mild fever.', is_prescription: false
            },
            {
                name: 'Rizatriptan 10mg', name_ur: 'رضا ٹرپٹن 10 ملی گرام',
                category_id: catMap['Brain / Neuro'],
                dosage: '1 tablet at onset of migraine.', is_prescription: true
            },
            {
                name: 'Amlodipine 5mg', name_ur: 'املودپائن 5 ملی گرام',
                category_id: catMap['Heart & BP'],
                dosage: '1 tablet daily.', is_prescription: true
            },
            {
                name: 'Salbutamol Inhaler', name_ur: 'سالبوٹامول انہیلر',
                category_id: catMap['Lungs'],
                dosage: '1-2 puffs when needed.', is_prescription: true
            },
            {
                name: 'Artemether + Lumefantrine', name_ur: 'ارٹیمتھر + لومفینٹرین',
                category_id: catMap['Fever / Infections'],
                dosage: 'As directed by doctor.', description: 'Used for Malaria treatment.', is_prescription: true
            },
            {
                name: 'Omeprazole 20mg', name_ur: 'امیپرازول 20 ملی گرام',
                category_id: catMap['Stomach / Digestive'],
                dosage: '1 capsule before breakfast.', description: 'For acidity and GERD.', is_prescription: false
            },
            {
                name: 'Loperamide 2mg', name_ur: 'لوپرامائیڈ 2 ملی گرام',
                category_id: catMap['Stomach / Digestive'],
                dosage: '1-2 tablets after each loose stool.', description: 'For Diarrhea control.', is_prescription: false
            },
            {
                name: 'Metronidazole 400mg', name_ur: 'میٹرو نیڈازول 400 ملی گرام',
                category_id: catMap['Female Health'],
                dosage: '1 tablet twice daily for 5-7 days.', description: 'For Bacterial Vaginosis.', is_prescription: true
            },
            {
                name: 'Fluconazole 150mg', name_ur: 'فلوکونازول 150 ملی گرام',
                category_id: catMap['Female Health'],
                dosage: 'Single dose.', description: 'For Vaginal Yeast Infection.', is_prescription: true
            },
            {
                name: 'Ciprofloxacin 500mg', name_ur: 'سپروفلوکساسین 500 ملی گرام',
                category_id: catMap['Female Health'],
                dosage: '1 tablet twice daily for 3-5 days.', description: 'For UTI.', is_prescription: true
            },
            {
                name: 'Ponstan (Mefenamic Acid)', name_ur: 'پونسٹان',
                category_id: catMap['Female Health'],
                dosage: '1 tablet twice daily during cycles.', description: 'For Painful Periods.', is_prescription: false
            }
        ];

        const medDocMap = {};
        for (const m of medicinesData) {
            const dr = await db.collection('medicines').add(m);
            medDocMap[m.name] = dr.id;
        }

        // 4. Mappings
        const mappings = [
            { s: 'Headache (Tension type)', m: 'Paracetamol 500mg' },
            { s: 'Migraine', m: 'Rizatriptan 10mg' },
            { s: 'Common Fever', m: 'Paracetamol 500mg' },
            { s: 'High Blood Pressure (Hypertension)', m: 'Amlodipine 5mg' },
            { s: 'Asthma', m: 'Salbutamol Inhaler' },
            { s: 'Malaria', m: 'Artemether + Lumefantrine' },
            { s: 'Acidity / GERD', m: 'Omeprazole 20mg' },
            { s: 'Diarrhea', m: 'Loperamide 2mg' },
            { s: 'Bacterial Vaginosis', m: 'Metronidazole 400mg' },
            { s: 'Vaginal Yeast Infection', m: 'Fluconazole 150mg' },
            { s: 'Urinary Tract Infection (UTI)', m: 'Ciprofloxacin 500mg' },
            { s: 'Painful Periods (Dysmenorrhea)', m: 'Ponstan (Mefenamic Acid)' }
        ];

        for (const map of mappings) {
            if (sympDocMap[map.s] && medDocMap[map.m]) {
                await db.collection('symptom_medicine_map').add({
                    symptom_id: sympDocMap[map.s],
                    medicine_id: medDocMap[map.m]
                });
            }
        }

        console.log('--- FINAL SEEDING COMPLETED SUCCESSFULLY ---');
        process.exit(0);
    } catch (err) {
        console.error('Seeding ERROR:', err);
        process.exit(1);
    }
}

seed();
