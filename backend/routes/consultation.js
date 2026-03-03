const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const consultationController = require('../controllers/consultation_controller');

router.post('/', auth, consultationController.createConsultation);
router.get('/history', auth, consultationController.getHistory);
router.get('/:id/pdf', auth, consultationController.generatePDF);
router.get('/category/:categoryName', consultationController.getMedicinesByCategory);

module.exports = router;
