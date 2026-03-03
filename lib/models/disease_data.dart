class DiseaseMedicine {
  final String diseaseName;
  final String medicine;
  final String category;
  final bool doctorRequired;

  const DiseaseMedicine({
    required this.diseaseName,
    required this.medicine,
    required this.category,
    this.doctorRequired = false,
  });
}

class DiseaseData {
  static const List<DiseaseMedicine> allDiseases = [
    // HEAD / NEURO
    DiseaseMedicine(diseaseName: 'Headache (Tension type)', medicine: 'Paracetamol, Ibuprofen', category: 'Brain / Neuro'),
    DiseaseMedicine(diseaseName: 'Migraine', medicine: 'Sumatriptan, Naproxen', category: 'Brain / Neuro'),
    DiseaseMedicine(diseaseName: 'Sinusitis', medicine: 'Amoxicillin (if bacterial), Cetirizine', category: 'Brain / Neuro'),
    DiseaseMedicine(diseaseName: 'Vertigo', medicine: 'Betahistine', category: 'Brain / Neuro'),

    // HEART & BLOOD PRESSURE
    DiseaseMedicine(diseaseName: 'High Blood Pressure (Hypertension)', medicine: 'Amlodipine, Losartan', category: 'Heart & BP'),
    DiseaseMedicine(diseaseName: 'Angina (Chest pain due to heart)', medicine: 'Nitroglycerin', category: 'Heart & BP'),
    DiseaseMedicine(diseaseName: 'High Cholesterol', medicine: 'Atorvastatin', category: 'Heart & BP'),
    DiseaseMedicine(diseaseName: 'Heart Failure', medicine: 'Furosemide, ACE inhibitors', category: 'Heart & BP'),

    // LUNGS
    DiseaseMedicine(diseaseName: 'Asthma', medicine: 'Salbutamol inhaler', category: 'Lungs'),
    DiseaseMedicine(diseaseName: 'Bronchitis', medicine: 'Cough syrup, Antibiotics (if bacterial)', category: 'Lungs'),
    DiseaseMedicine(diseaseName: 'Pneumonia', medicine: 'Azithromycin / Ceftriaxone', category: 'Lungs', doctorRequired: true),

    // FEVER / INFECTIONS
    DiseaseMedicine(diseaseName: 'Common Fever', medicine: 'Paracetamol', category: 'Fever / Infections'),
    DiseaseMedicine(diseaseName: 'Typhoid', medicine: 'Cefixime', category: 'Fever / Infections', doctorRequired: true),
    DiseaseMedicine(diseaseName: 'Dengue (Supportive care only)', medicine: 'Paracetamol (No Ibuprofen)', category: 'Fever / Infections'),
    DiseaseMedicine(diseaseName: 'Malaria', medicine: 'Artemether-Lumefantrine', category: 'Fever / Infections'),

    // ALLERGY
    DiseaseMedicine(diseaseName: 'Allergic Rhinitis', medicine: 'Cetirizine', category: 'Allergy'),
    DiseaseMedicine(diseaseName: 'Skin Allergy', medicine: 'Hydrocortisone cream', category: 'Allergy'),

    // STOMACH / DIGESTIVE
    DiseaseMedicine(diseaseName: 'Acidity / GERD', medicine: 'Omeprazole', category: 'Stomach / Digestive'),
    DiseaseMedicine(diseaseName: 'Gastritis', medicine: 'Pantoprazole', category: 'Stomach / Digestive'),
    DiseaseMedicine(diseaseName: 'Diarrhea', medicine: 'ORS, Loperamide', category: 'Stomach / Digestive'),
    DiseaseMedicine(diseaseName: 'Constipation', medicine: 'Lactulose', category: 'Stomach / Digestive'),
    DiseaseMedicine(diseaseName: 'Stomach Ulcer', medicine: 'Omeprazole + Antibiotics', category: 'Stomach / Digestive'),
    DiseaseMedicine(diseaseName: 'Food Poisoning', medicine: 'ORS, Ciprofloxacin', category: 'Stomach / Digestive', doctorRequired: true),

    // BOTTOM / RECTAL AREA
    DiseaseMedicine(diseaseName: 'Piles (Hemorrhoids)', medicine: 'Anobliss cream, Sitz bath', category: 'Bottom / Rectal'),
    DiseaseMedicine(diseaseName: 'Anal Fissure', medicine: 'Nitroglycerin ointment', category: 'Bottom / Rectal'),
    DiseaseMedicine(diseaseName: 'Anal Infection', medicine: 'Metronidazole', category: 'Bottom / Rectal'),

    // VAGINA / FEMALE REPRODUCTIVE
    DiseaseMedicine(diseaseName: 'Vaginal Yeast Infection', medicine: 'Clotrimazole', category: 'Female Health'),
    DiseaseMedicine(diseaseName: 'Bacterial Vaginosis', medicine: 'Metronidazole', category: 'Female Health'),
    DiseaseMedicine(diseaseName: 'Urinary Tract Infection (UTI)', medicine: 'Nitrofurantoin', category: 'Female Health'),
    DiseaseMedicine(diseaseName: 'PCOS', medicine: 'Metformin', category: 'Female Health', doctorRequired: true),
    DiseaseMedicine(diseaseName: 'Painful Periods (Dysmenorrhea)', medicine: 'Ibuprofen', category: 'Female Health'),
  ];
}

