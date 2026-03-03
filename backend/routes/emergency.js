const express = require('express');
const router = express.Router();
const emergencyController = require('../controllers/emergency_controller');

router.get('/hospitals', emergencyController.getHospitals);

module.exports = router;
