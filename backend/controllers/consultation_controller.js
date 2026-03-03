const admin = require('firebase-admin');
const { sendSuccess, sendError } = require('../utils/response');
const PDFDocument = require('pdfkit');
const Joi = require('joi');

const consultationSchema = Joi.object({
    symptoms: Joi.array().items(Joi.string()).min(1).required()
});

exports.createConsultation = async (req, res) => {
    try {
        const { error } = consultationSchema.validate(req.body);
        if (error) return sendError(res, error.details[0].message, 400);

        const { symptoms } = req.body;
        const lang = req.query.lang || 'en';
        const db = admin.firestore();

        // 1. Fetch matching symptoms
        const symptomsSnapshot = await db.collection('symptoms')
            .where('name', 'in', symptoms)
            .get();

        const matchedSymptoms = symptomsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        const symptomIds = matchedSymptoms.map(s => s.id);

        if (symptomIds.length === 0) {
            return sendSuccess(res, { symptoms_provided: symptoms, suggestions: [] });
        }

        // Get Category Name for "Suggested Disease"
        let suggestedDisease = 'General Condition';
        if (matchedSymptoms.length > 0) {
            const firstCatId = matchedSymptoms[0].category_id;
            const catDoc = await db.collection('categories').doc(firstCatId).get();
            if (catDoc.exists) {
                suggestedDisease = (lang === 'ur' && catDoc.data().name_ur) ? catDoc.data().name_ur : catDoc.data().name;
            }
        }

        // 2. Fetch maps to get Med IDs
        const mapsSnapshot = await db.collection('symptom_medicine_map')
            .where('symptom_id', 'in', symptomIds)
            .get();

        const medicineIdsRaw = mapsSnapshot.docs.map(doc => doc.data().medicine_id);
        const uniqueMedicineIds = [...new Set(medicineIdsRaw)];

        if (uniqueMedicineIds.length === 0) {
            return sendSuccess(res, { symptoms_provided: symptoms, suggestions: [], suggested_disease: suggestedDisease });
        }

        // 3. Fetch details
        const medicinesSnapshot = await db.collection('medicines').get();

        const medicines = medicinesSnapshot.docs
            .filter(doc => uniqueMedicineIds.includes(doc.id))
            .map(doc => ({ id: doc.id, ...doc.data() }));

        // 4. Transform for Language and Flags
        const processedMedicines = medicines.map(med => {
            let warningFlags = [];
            if (med.is_prescription) warningFlags.push(lang === 'ur' ? 'ڈاکٹر کا نسخہ ضروری ہے' : 'Prescription Required');
            if (med.is_antibiotic) warningFlags.push(lang === 'ur' ? 'اینٹی بائیوٹک - ڈاکٹر کی ضرورت ہے' : 'Antibiotic - Doctor Required');

            return {
                ...med,
                name: (lang === 'ur' && med.name_ur) ? med.name_ur : (med.name || ''),
                description: (lang === 'ur' && med.description_ur) ? med.description_ur : (med.description || ''),
                dosage: (lang === 'ur' && med.dosage_ur) ? med.dosage_ur : (med.dosage || ''),
                warning: (lang === 'ur' && med.warning_ur) ? med.warning_ur : (med.warning || ''),
                warning_flags: warningFlags
            };
        });

        // 5. Save to history
        const historyData = {
            user_id: req.user._id,
            user_name: req.user.name,
            selected_symptoms: symptoms,
            suggested_disease: suggestedDisease,
            suggested_medicines: processedMedicines,
            created_at: admin.firestore.FieldValue.serverTimestamp()
        };

        const historyRef = await db.collection('consultation_history').add(historyData);

        sendSuccess(res, {
            consultation_id: historyRef.id,
            symptoms_provided: symptoms,
            suggested_disease: suggestedDisease,
            suggestions: processedMedicines,
        });
    } catch (err) {
        console.error('CONSULTATION_ERROR:', err);
        sendError(res, err.message || 'Internal Server Error', 500);
    }
};

exports.getHistory = async (req, res) => {
    try {
        const db = admin.firestore();
        const snapshot = await db.collection('consultation_history')
            .where('user_id', '==', req.user._id)
            .orderBy('created_at', 'desc')
            .get();

        const histories = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        sendSuccess(res, histories);
    } catch (err) {
        console.error('HISTORY_ERROR:', err);
        sendError(res, err.message || 'Internal Server Error', 500);
    }
};

exports.generatePDF = async (req, res) => {
    try {
        const db = admin.firestore();
        const docRef = db.collection('consultation_history').doc(req.params.id);
        const historyDoc = await docRef.get();

        if (!historyDoc.exists || historyDoc.data().user_id !== req.user._id) {
            return sendError(res, 'Consultation not found', 404);
        }

        const history = historyDoc.data();
        const doc = new PDFDocument({ margin: 50 });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=SehatGuide_Report_${historyDoc.id}.pdf`);

        doc.pipe(res);

        // Header
        doc.fontSize(24).fillColor('#00B4D8').text('Sehat Guide', { align: 'center' });
        doc.fontSize(16).fillColor('#444').text('Consultation Report', { align: 'center' });
        doc.moveDown();
        doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke('#eee');
        doc.moveDown();

        // Details Table-like layout
        doc.fillColor('#000').fontSize(12);

        const drawField = (label, value) => {
            doc.font('Helvetica-Bold').text(`${label}: `, { continued: true })
                .font('Helvetica').text(value || 'N/A');
            doc.moveDown(0.5);
        };

        drawField('Patient Name', history.user_name || 'User');
        drawField('Date & Time', history.created_at ? history.created_at.toDate().toLocaleString() : 'N/A');
        drawField('Selected Symptoms', history.selected_symptoms.join(', '));
        drawField('Suggested Disease', history.suggested_disease || 'General Condition');

        doc.moveDown();
        doc.fontSize(14).font('Helvetica-Bold').text('Recommended Medicines:', { underline: true });
        doc.moveDown(0.5);

        if (history.suggested_medicines && history.suggested_medicines.length > 0) {
            history.suggested_medicines.forEach((med, index) => {
                doc.fontSize(12).font('Helvetica-Bold').text(`${index + 1}. ${med.name}`);
                doc.font('Helvetica').fontSize(10).text(`Dosage: ${med.dosage || 'As directed'}`);
                if (med.warning) {
                    doc.fillColor('red').text(`Warning: ${med.warning}`).fillColor('black');
                }
                doc.moveDown(0.5);
            });
        } else {
            doc.text('No specific medicines suggested. Please consult a professional.');
        }

        doc.moveDown(2);
        doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke('#eee');
        doc.moveDown();

        // Footer / Warning
        doc.fontSize(10).fillColor('#E53935').font('Helvetica-Bold')
            .text('DOCTOR WARNING:', { align: 'center' });
        doc.font('Helvetica').text('This report is for informational purposes only and is not a substitute for professional medical advice. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
            { align: 'center' });

        doc.end();
    } catch (err) {
        console.error('PDF_ERROR:', err);
        if (!res.headersSent) sendError(res, err.message || 'Internal Server Error', 500);
        else res.end();
    }
};

exports.getMedicinesByCategory = async (req, res) => {
    try {
        const { categoryName } = req.params;
        const lang = req.query.lang || 'en';
        const db = admin.firestore();

        // 1. Find category
        const catSnapshot = await db.collection('categories').get();

        const category = catSnapshot.docs.find(doc =>
            doc.data().name === categoryName || doc.data().name_ur === categoryName
        );

        if (!category) return sendError(res, 'Category not found', 404);

        // 2. Find medicines
        const medSnapshot = await db.collection('medicines')
            .where('category_id', '==', category.id)
            .get();

        const processedMedicines = medSnapshot.docs.map(doc => {
            const med = doc.data();
            return {
                id: doc.id,
                ...med,
                name: (lang === 'ur' && med.name_ur) ? med.name_ur : med.name,
                description: (lang === 'ur' && med.description_ur) ? med.description_ur : med.description,
                dosage: (lang === 'ur' && med.dosage_ur) ? med.dosage_ur : med.dosage,
                warning: (lang === 'ur' && med.warning_ur) ? med.warning_ur : (med.warning || ''),
            };
        });

        sendSuccess(res, processedMedicines);
    } catch (err) {
        console.error('CATEGORY_ERROR:', err);
        sendError(res, err.message || 'Internal Server Error', 500);
    }
};
