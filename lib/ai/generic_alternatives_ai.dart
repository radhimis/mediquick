import 'package:supabase_flutter/supabase_flutter.dart';

class GenericAlternativesAI {
  final SupabaseClient _client = Supabase.instance.client;

  // Comprehensive database of Indian pharmaceutical companies and their generic medicines
  final Map<String, List<Map<String, dynamic>>> _indianGenericMappings = {
    // Sun Pharmaceutical Industries Ltd.
    'atorvastatin': [
      {'name': 'Atorvastatin', 'strength': '10mg', 'savings': 85, 'manufacturer': 'Sun Pharma', 'brand': 'Lipitor'},
      {'name': 'Atorvastatin', 'strength': '20mg', 'savings': 82, 'manufacturer': 'Sun Pharma', 'brand': 'Lipitor'},
      {'name': 'Atorvastatin', 'strength': '40mg', 'savings': 80, 'manufacturer': 'Sun Pharma', 'brand': 'Lipitor'},
    ],
    'simvastatin': [
      {'name': 'Simvastatin', 'strength': '10mg', 'savings': 87, 'manufacturer': 'Sun Pharma', 'brand': 'Zocor'},
      {'name': 'Simvastatin', 'strength': '20mg', 'savings': 85, 'manufacturer': 'Sun Pharma', 'brand': 'Zocor'},
    ],
    'montelukast': [
      {'name': 'Montelukast', 'strength': '10mg', 'savings': 78, 'manufacturer': 'Sun Pharma', 'brand': 'Singulair'},
      {'name': 'Montelukast', 'strength': '5mg', 'savings': 82, 'manufacturer': 'Sun Pharma', 'brand': 'Singulair'},
    ],
    'losartan': [
      {'name': 'Losartan', 'strength': '50mg', 'savings': 84, 'manufacturer': 'Sun Pharma', 'brand': 'Cozaar'},
      {'name': 'Losartan', 'strength': '100mg', 'savings': 81, 'manufacturer': 'Sun Pharma', 'brand': 'Cozaar'},
    ],
    'amlodipine': [
      {'name': 'Amlodipine', 'strength': '5mg', 'savings': 88, 'manufacturer': 'Sun Pharma', 'brand': 'Norvasc'},
      {'name': 'Amlodipine', 'strength': '10mg', 'savings': 85, 'manufacturer': 'Sun Pharma', 'brand': 'Norvasc'},
    ],
    'atenolol': [
      {'name': 'Atenolol', 'strength': '50mg', 'savings': 90, 'manufacturer': 'Sun Pharma', 'brand': 'Tenormin'},
      {'name': 'Atenolol', 'strength': '100mg', 'savings': 87, 'manufacturer': 'Sun Pharma', 'brand': 'Tenormin'},
    ],
    'omeprazole': [
      {'name': 'Omeprazole', 'strength': '20mg', 'savings': 86, 'manufacturer': 'Sun Pharma', 'brand': 'Prilosec'},
      {'name': 'Omeprazole', 'strength': '40mg', 'savings': 83, 'manufacturer': 'Sun Pharma', 'brand': 'Prilosec'},
    ],
    'lansoprazole': [
      {'name': 'Lansoprazole', 'strength': '30mg', 'savings': 84, 'manufacturer': 'Sun Pharma', 'brand': 'Prevacid'},
    ],
    'fluoxetine': [
      {'name': 'Fluoxetine', 'strength': '20mg', 'savings': 82, 'manufacturer': 'Sun Pharma', 'brand': 'Prozac'},
      {'name': 'Fluoxetine', 'strength': '40mg', 'savings': 79, 'manufacturer': 'Sun Pharma', 'brand': 'Prozac'},
    ],
    'sertraline': [
      {'name': 'Sertraline', 'strength': '50mg', 'savings': 81, 'manufacturer': 'Sun Pharma', 'brand': 'Zoloft'},
      {'name': 'Sertraline', 'strength': '100mg', 'savings': 78, 'manufacturer': 'Sun Pharma', 'brand': 'Zoloft'},
    ],
    'paroxetine': [
      {'name': 'Paroxetine', 'strength': '20mg', 'savings': 80, 'manufacturer': 'Sun Pharma', 'brand': 'Paxil'},
    ],
    'azithromycin': [
      {'name': 'Azithromycin', 'strength': '250mg', 'savings': 85, 'manufacturer': 'Sun Pharma', 'brand': 'Zithromax'},
      {'name': 'Azithromycin', 'strength': '500mg', 'savings': 82, 'manufacturer': 'Sun Pharma', 'brand': 'Zithromax'},
    ],
    'clarithromycin': [
      {'name': 'Clarithromycin', 'strength': '250mg', 'savings': 83, 'manufacturer': 'Sun Pharma', 'brand': 'Biaxin'},
      {'name': 'Clarithromycin', 'strength': '500mg', 'savings': 80, 'manufacturer': 'Sun Pharma', 'brand': 'Biaxin'},
    ],

    // Cipla Ltd.
    'sildenafil': [
      {'name': 'Sildenafil', 'strength': '25mg', 'savings': 88, 'manufacturer': 'Cipla', 'brand': 'Viagra'},
      {'name': 'Sildenafil', 'strength': '50mg', 'savings': 85, 'manufacturer': 'Cipla', 'brand': 'Viagra'},
      {'name': 'Sildenafil', 'strength': '100mg', 'savings': 82, 'manufacturer': 'Cipla', 'brand': 'Viagra'},
    ],
    'esomeprazole': [
      {'name': 'Esomeprazole', 'strength': '20mg', 'savings': 86, 'manufacturer': 'Cipla', 'brand': 'Nexium'},
      {'name': 'Esomeprazole', 'strength': '40mg', 'savings': 83, 'manufacturer': 'Cipla', 'brand': 'Nexium'},
    ],
    'clopidogrel': [
      {'name': 'Clopidogrel', 'strength': '75mg', 'savings': 88, 'manufacturer': 'Cipla', 'brand': 'Plavix'},
    ],
    'celecoxib': [
      {'name': 'Celecoxib', 'strength': '100mg', 'savings': 84, 'manufacturer': 'Cipla', 'brand': 'Celebrex'},
      {'name': 'Celecoxib', 'strength': '200mg', 'savings': 81, 'manufacturer': 'Cipla', 'brand': 'Celebrex'},
    ],
    'rosiglitazone': [
      {'name': 'Rosiglitazone', 'strength': '4mg', 'savings': 87, 'manufacturer': 'Cipla', 'brand': 'Avandia'},
      {'name': 'Rosiglitazone', 'strength': '8mg', 'savings': 84, 'manufacturer': 'Cipla', 'brand': 'Avandia'},
    ],
    'amoxicillin': [
      {'name': 'Amoxicillin', 'strength': '250mg', 'savings': 90, 'manufacturer': 'Cipla', 'brand': 'Amoxil'},
      {'name': 'Amoxicillin', 'strength': '500mg', 'savings': 87, 'manufacturer': 'Cipla', 'brand': 'Amoxil'},
    ],
    'amoxicillin_clavulanate': [
      {'name': 'Amoxicillin/Clavulanate', 'strength': '875/125mg', 'savings': 85, 'manufacturer': 'Cipla', 'brand': 'Augmentin'},
    ],
    'ibuprofen': [
      {'name': 'Ibuprofen', 'strength': '200mg', 'savings': 92, 'manufacturer': 'Cipla', 'brand': 'Advil'},
      {'name': 'Ibuprofen', 'strength': '400mg', 'savings': 89, 'manufacturer': 'Cipla', 'brand': 'Advil'},
      {'name': 'Ibuprofen', 'strength': '600mg', 'savings': 86, 'manufacturer': 'Cipla', 'brand': 'Advil'},
    ],
    'acetaminophen': [
      {'name': 'Acetaminophen', 'strength': '325mg', 'savings': 95, 'manufacturer': 'Cipla', 'brand': 'Tylenol'},
      {'name': 'Acetaminophen', 'strength': '500mg', 'savings': 93, 'manufacturer': 'Cipla', 'brand': 'Tylenol'},
    ],

    // Dr. Reddy's Laboratories
    'metformin': [
      {'name': 'Metformin', 'strength': '500mg', 'savings': 88, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Glucophage'},
      {'name': 'Metformin', 'strength': '850mg', 'savings': 85, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Glucophage'},
      {'name': 'Metformin', 'strength': '1000mg', 'savings': 82, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Glucophage'},
    ],
    'pioglitazone': [
      {'name': 'Pioglitazone', 'strength': '15mg', 'savings': 84, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Actos'},
      {'name': 'Pioglitazone', 'strength': '30mg', 'savings': 81, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Actos'},
    ],
    'pioglitazone_metformin': [
      {'name': 'Pioglitazone/Metformin', 'strength': '15/500mg', 'savings': 83, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Actoplus Met'},
    ],
    'fluticasone': [
      {'name': 'Fluticasone', 'strength': '50mcg', 'savings': 86, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Flovent'},
      {'name': 'Fluticasone', 'strength': '100mcg', 'savings': 83, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Flovent'},
    ],
    'fluticasone_salmeterol': [
      {'name': 'Fluticasone/Salmeterol', 'strength': '100/50mcg', 'savings': 81, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Advair'},
      {'name': 'Fluticasone/Salmeterol', 'strength': '250/50mcg', 'savings': 78, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Advair'},
    ],
    'rofecoxib': [
      {'name': 'Rofecoxib', 'strength': '12.5mg', 'savings': 85, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Vioxx'},
      {'name': 'Rofecoxib', 'strength': '25mg', 'savings': 82, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Vioxx'},
    ],
    'valdecoxib': [
      {'name': 'Valdecoxib', 'strength': '10mg', 'savings': 87, 'manufacturer': 'Dr. Reddy\'s', 'brand': 'Bextra'},
    ],

    // Ranbaxy Laboratories (now part of Sun Pharma)
    'ciprofloxacin': [
      {'name': 'Ciprofloxacin', 'strength': '250mg', 'savings': 89, 'manufacturer': 'Ranbaxy', 'brand': 'Cipro'},
      {'name': 'Ciprofloxacin', 'strength': '500mg', 'savings': 86, 'manufacturer': 'Ranbaxy', 'brand': 'Cipro'},
    ],
    'levofloxacin': [
      {'name': 'Levofloxacin', 'strength': '250mg', 'savings': 84, 'manufacturer': 'Ranbaxy', 'brand': 'Levaquin'},
      {'name': 'Levofloxacin', 'strength': '500mg', 'savings': 81, 'manufacturer': 'Ranbaxy', 'brand': 'Levaquin'},
    ],
    'diclofenac': [
      {'name': 'Diclofenac', 'strength': '50mg', 'savings': 91, 'manufacturer': 'Ranbaxy', 'brand': 'Voltaren'},
      {'name': 'Diclofenac', 'strength': '75mg', 'savings': 88, 'manufacturer': 'Ranbaxy', 'brand': 'Voltaren'},
    ],
    'enalapril': [
      {'name': 'Enalapril', 'strength': '5mg', 'savings': 87, 'manufacturer': 'Ranbaxy', 'brand': 'Vasotec'},
      {'name': 'Enalapril', 'strength': '10mg', 'savings': 84, 'manufacturer': 'Ranbaxy', 'brand': 'Vasotec'},
    ],
    'ramipril': [
      {'name': 'Ramipril', 'strength': '2.5mg', 'savings': 85, 'manufacturer': 'Ranbaxy', 'brand': 'Altace'},
      {'name': 'Ramipril', 'strength': '5mg', 'savings': 82, 'manufacturer': 'Ranbaxy', 'brand': 'Altace'},
    ],

    // Lupin Limited
    'gabapentin': [
      {'name': 'Gabapentin', 'strength': '100mg', 'savings': 86, 'manufacturer': 'Lupin', 'brand': 'Neurontin'},
      {'name': 'Gabapentin', 'strength': '300mg', 'savings': 83, 'manufacturer': 'Lupin', 'brand': 'Neurontin'},
      {'name': 'Gabapentin', 'strength': '400mg', 'savings': 80, 'manufacturer': 'Lupin', 'brand': 'Neurontin'},
    ],
    'pregabalin': [
      {'name': 'Pregabalin', 'strength': '75mg', 'savings': 84, 'manufacturer': 'Lupin', 'brand': 'Lyrica'},
      {'name': 'Pregabalin', 'strength': '150mg', 'savings': 81, 'manufacturer': 'Lupin', 'brand': 'Lyrica'},
    ],
    'doxycycline': [
      {'name': 'Doxycycline', 'strength': '100mg', 'savings': 88, 'manufacturer': 'Lupin', 'brand': 'Vibramycin'},
    ],
    'minocycline': [
      {'name': 'Minocycline', 'strength': '50mg', 'savings': 85, 'manufacturer': 'Lupin', 'brand': 'Minocin'},
      {'name': 'Minocycline', 'strength': '100mg', 'savings': 82, 'manufacturer': 'Lupin', 'brand': 'Minocin'},
    ],
    'hydrochlorothiazide': [
      {'name': 'Hydrochlorothiazide', 'strength': '12.5mg', 'savings': 90, 'manufacturer': 'Lupin', 'brand': 'Microzide'},
      {'name': 'Hydrochlorothiazide', 'strength': '25mg', 'savings': 87, 'manufacturer': 'Lupin', 'brand': 'Microzide'},
    ],

    // Aurobindo Pharma
    'warfarin': [
      {'name': 'Warfarin', 'strength': '2mg', 'savings': 89, 'manufacturer': 'Aurobindo', 'brand': 'Coumadin'},
      {'name': 'Warfarin', 'strength': '5mg', 'savings': 86, 'manufacturer': 'Aurobindo', 'brand': 'Coumadin'},
    ],
    'digoxin': [
      {'name': 'Digoxin', 'strength': '0.125mg', 'savings': 87, 'manufacturer': 'Aurobindo', 'brand': 'Lanoxin'},
      {'name': 'Digoxin', 'strength': '0.25mg', 'savings': 84, 'manufacturer': 'Aurobindo', 'brand': 'Lanoxin'},
    ],
    'furosemide': [
      {'name': 'Furosemide', 'strength': '20mg', 'savings': 91, 'manufacturer': 'Aurobindo', 'brand': 'Lasix'},
      {'name': 'Furosemide', 'strength': '40mg', 'savings': 88, 'manufacturer': 'Aurobindo', 'brand': 'Lasix'},
    ],
    'spironolactone': [
      {'name': 'Spironolactone', 'strength': '25mg', 'savings': 85, 'manufacturer': 'Aurobindo', 'brand': 'Aldactone'},
      {'name': 'Spironolactone', 'strength': '50mg', 'savings': 82, 'manufacturer': 'Aurobindo', 'brand': 'Aldactone'},
    ],
    'phenytoin': [
      {'name': 'Phenytoin', 'strength': '100mg', 'savings': 86, 'manufacturer': 'Aurobindo', 'brand': 'Dilantin'},
    ],

    // Cadila Healthcare (Zydus Cadila)
    'allopurinol': [
      {'name': 'Allopurinol', 'strength': '100mg', 'savings': 88, 'manufacturer': 'Zydus Cadila', 'brand': 'Zyloprim'},
      {'name': 'Allopurinol', 'strength': '300mg', 'savings': 85, 'manufacturer': 'Zydus Cadila', 'brand': 'Zyloprim'},
    ],
    'colchicine': [
      {'name': 'Colchicine', 'strength': '0.6mg', 'savings': 87, 'manufacturer': 'Zydus Cadila', 'brand': 'Colcrys'},
    ],
    'probenecid': [
      {'name': 'Probenecid', 'strength': '500mg', 'savings': 84, 'manufacturer': 'Zydus Cadila', 'brand': 'Benemid'},
    ],
    'methotrexate': [
      {'name': 'Methotrexate', 'strength': '2.5mg', 'savings': 86, 'manufacturer': 'Zydus Cadila', 'brand': 'Trexall'},
    ],
    'hydroxychloroquine': [
      {'name': 'Hydroxychloroquine', 'strength': '200mg', 'savings': 83, 'manufacturer': 'Zydus Cadila', 'brand': 'Plaquenil'},
    ],

    // Torrent Pharmaceuticals
    'valsartan': [
      {'name': 'Valsartan', 'strength': '80mg', 'savings': 85, 'manufacturer': 'Torrent', 'brand': 'Diovan'},
      {'name': 'Valsartan', 'strength': '160mg', 'savings': 82, 'manufacturer': 'Torrent', 'brand': 'Diovan'},
    ],
    'telmisartan': [
      {'name': 'Telmisartan', 'strength': '40mg', 'savings': 84, 'manufacturer': 'Torrent', 'brand': 'Micardis'},
      {'name': 'Telmisartan', 'strength': '80mg', 'savings': 81, 'manufacturer': 'Torrent', 'brand': 'Micardis'},
    ],
    'irbesartan': [
      {'name': 'Irbesartan', 'strength': '150mg', 'savings': 83, 'manufacturer': 'Torrent', 'brand': 'Avapro'},
      {'name': 'Irbesartan', 'strength': '300mg', 'savings': 80, 'manufacturer': 'Torrent', 'brand': 'Avapro'},
    ],
    'olmesartan': [
      {'name': 'Olmesartan', 'strength': '20mg', 'savings': 86, 'manufacturer': 'Torrent', 'brand': 'Benicar'},
      {'name': 'Olmesartan', 'strength': '40mg', 'savings': 83, 'manufacturer': 'Torrent', 'brand': 'Benicar'},
    ],

    // Alkem Laboratories
    'rabeprazole': [
      {'name': 'Rabeprazole', 'strength': '20mg', 'savings': 87, 'manufacturer': 'Alkem', 'brand': 'Aciphex'},
    ],
    'pantoprazole': [
      {'name': 'Pantoprazole', 'strength': '40mg', 'savings': 85, 'manufacturer': 'Alkem', 'brand': 'Protonix'},
    ],
    'dexlansoprazole': [
      {'name': 'Dexlansoprazole', 'strength': '30mg', 'savings': 84, 'manufacturer': 'Alkem', 'brand': 'Dexilant'},
      {'name': 'Dexlansoprazole', 'strength': '60mg', 'savings': 81, 'manufacturer': 'Alkem', 'brand': 'Dexilant'},
    ],
    'esomeprazole_strontium': [
      {'name': 'Esomeprazole Strontium', 'strength': '49.3mg', 'savings': 83, 'manufacturer': 'Alkem', 'brand': 'NexIUM 24HR'},
    ],

    // Glenmark Pharmaceuticals
    'desloratadine': [
      {'name': 'Desloratadine', 'strength': '5mg', 'savings': 86, 'manufacturer': 'Glenmark', 'brand': 'Clarinex'},
    ],
    'fexofenadine': [
      {'name': 'Fexofenadine', 'strength': '60mg', 'savings': 88, 'manufacturer': 'Glenmark', 'brand': 'Allegra'},
      {'name': 'Fexofenadine', 'strength': '180mg', 'savings': 85, 'manufacturer': 'Glenmark', 'brand': 'Allegra'},
    ],
    'montelukast_sodium': [
      {'name': 'Montelukast Sodium', 'strength': '10mg', 'savings': 84, 'manufacturer': 'Glenmark', 'brand': 'Singulair'},
    ],
    'zafirlukast': [
      {'name': 'Zafirlukast', 'strength': '20mg', 'savings': 82, 'manufacturer': 'Glenmark', 'brand': 'Accolate'},
    ],

    // Wockhardt Ltd.
    'cefuroxime': [
      {'name': 'Cefuroxime', 'strength': '250mg', 'savings': 87, 'manufacturer': 'Wockhardt', 'brand': 'Ceftin'},
      {'name': 'Cefuroxime', 'strength': '500mg', 'savings': 84, 'manufacturer': 'Wockhardt', 'brand': 'Ceftin'},
    ],
    'cefadroxil': [
      {'name': 'Cefadroxil', 'strength': '500mg', 'savings': 89, 'manufacturer': 'Wockhardt', 'brand': 'Duricef'},
    ],
    'cefpodoxime': [
      {'name': 'Cefpodoxime', 'strength': '100mg', 'savings': 86, 'manufacturer': 'Wockhardt', 'brand': 'Vantin'},
      {'name': 'Cefpodoxime', 'strength': '200mg', 'savings': 83, 'manufacturer': 'Wockhardt', 'brand': 'Vantin'},
    ],

    // Ipca Laboratories
    'amiodarone': [
      {'name': 'Amiodarone', 'strength': '100mg', 'savings': 85, 'manufacturer': 'Ipca', 'brand': 'Cordarone'},
      {'name': 'Amiodarone', 'strength': '200mg', 'savings': 82, 'manufacturer': 'Ipca', 'brand': 'Cordarone'},
    ],
    'propafenone': [
      {'name': 'Propafenone', 'strength': '150mg', 'savings': 84, 'manufacturer': 'Ipca', 'brand': 'Rythmol'},
    ],
    'quinidine': [
      {'name': 'Quinidine', 'strength': '200mg', 'savings': 86, 'manufacturer': 'Ipca', 'brand': 'Quinidex'},
    ],
    'procainamide': [
      {'name': 'Procainamide', 'strength': '250mg', 'savings': 83, 'manufacturer': 'Ipca', 'brand': 'Pronestyl'},
    ],

    // More common medicines from various Indian manufacturers
    'aspirin': [
      {'name': 'Aspirin', 'strength': '81mg', 'savings': 95, 'manufacturer': 'Various Indian', 'brand': 'Bayer'},
      {'name': 'Aspirin', 'strength': '325mg', 'savings': 93, 'manufacturer': 'Various Indian', 'brand': 'Bayer'},
    ],
    'lisinopril': [
      {'name': 'Lisinopril', 'strength': '5mg', 'savings': 89, 'manufacturer': 'Various Indian', 'brand': 'Prinivil'},
      {'name': 'Lisinopril', 'strength': '10mg', 'savings': 86, 'manufacturer': 'Various Indian', 'brand': 'Prinivil'},
    ],
    'metoprolol': [
      {'name': 'Metoprolol', 'strength': '25mg', 'savings': 88, 'manufacturer': 'Various Indian', 'brand': 'Lopressor'},
      {'name': 'Metoprolol', 'strength': '50mg', 'savings': 85, 'manufacturer': 'Various Indian', 'brand': 'Lopressor'},
    ],
    'prednisone': [
      {'name': 'Prednisone', 'strength': '5mg', 'savings': 91, 'manufacturer': 'Various Indian', 'brand': 'Deltasone'},
      {'name': 'Prednisone', 'strength': '10mg', 'savings': 88, 'manufacturer': 'Various Indian', 'brand': 'Deltasone'},
    ],
    'hydrocodone_acetaminophen': [
      {'name': 'Hydrocodone/Acetaminophen', 'strength': '5/325mg', 'savings': 84, 'manufacturer': 'Various Indian', 'brand': 'Vicodin'},
      {'name': 'Hydrocodone/Acetaminophen', 'strength': '7.5/325mg', 'savings': 81, 'manufacturer': 'Various Indian', 'brand': 'Vicodin'},
    ],
    'oxycodone': [
      {'name': 'Oxycodone', 'strength': '5mg', 'savings': 83, 'manufacturer': 'Various Indian', 'brand': 'OxyContin'},
      {'name': 'Oxycodone', 'strength': '10mg', 'savings': 80, 'manufacturer': 'Various Indian', 'brand': 'OxyContin'},
    ],
  };

  // Legacy mappings for backward compatibility
  final Map<String, List<Map<String, dynamic>>> _genericMappings = {
    'viagra': [
      {'name': 'Sildenafil', 'strength': '100mg', 'savings': 80, 'manufacturer': 'Cipla'},
      {'name': 'Sildenafil', 'strength': '50mg', 'savings': 75, 'manufacturer': 'Sun Pharma'},
    ],
    'lipitor': [
      {'name': 'Atorvastatin', 'strength': '10mg', 'savings': 85, 'manufacturer': 'Dr. Reddy\'s'},
      {'name': 'Atorvastatin', 'strength': '20mg', 'savings': 82, 'manufacturer': 'Ranbaxy'},
    ],
    'advil': [
      {'name': 'Ibuprofen', 'strength': '200mg', 'savings': 90, 'manufacturer': 'Generic'},
      {'name': 'Ibuprofen', 'strength': '400mg', 'savings': 88, 'manufacturer': 'Generic'},
    ],
    'tylenol': [
      {'name': 'Acetaminophen', 'strength': '500mg', 'savings': 95, 'manufacturer': 'Generic'},
    ],
    'singulair': [
      {'name': 'Montelukast', 'strength': '10mg', 'savings': 78, 'manufacturer': 'Cipla'},
      {'name': 'Montelukast', 'strength': '5mg', 'savings': 82, 'manufacturer': 'Sun Pharma'},
    ],
    'plavix': [
      {'name': 'Clopidogrel', 'strength': '75mg', 'savings': 88, 'manufacturer': 'Dr. Reddy\'s'},
    ],
    'nexium': [
      {'name': 'Esomeprazole', 'strength': '20mg', 'savings': 85, 'manufacturer': 'Ranbaxy'},
      {'name': 'Esomeprazole', 'strength': '40mg', 'savings': 83, 'manufacturer': 'Cipla'},
    ],
    'zocor': [
      {'name': 'Simvastatin', 'strength': '10mg', 'savings': 87, 'manufacturer': 'Sun Pharma'},
      {'name': 'Simvastatin', 'strength': '20mg', 'savings': 85, 'manufacturer': 'Dr. Reddy\'s'},
    ],
    'cozaar': [
      {'name': 'Losartan', 'strength': '50mg', 'savings': 84, 'manufacturer': 'Cipla'},
      {'name': 'Losartan', 'strength': '100mg', 'savings': 81, 'manufacturer': 'Ranbaxy'},
    ],
  };

  // Common medicine name variations and brand-to-generic mappings
  final Map<String, String> _brandToGeneric = {
    // Cardiovascular
    'lipitor': 'atorvastatin',
    'zocor': 'simvastatin',
    'plavix': 'clopidogrel',
    'cozaar': 'losartan',
    'norvasc': 'amlodipine',
    'tenormin': 'atenolol',
    'diovan': 'valsartan',
    'micardis': 'telmisartan',
    'avapro': 'irbesartan',
    'benicar': 'olmesartan',
    'vasotec': 'enalapril',
    'altace': 'ramipril',
    'prinivil': 'lisinopril',
    'lopressor': 'metoprolol',
    'cordarone': 'amiodarone',
    'rythmol': 'propafenone',
    'quinidex': 'quinidine',
    'pronestyl': 'procainamide',

    // Gastrointestinal
    'nexium': 'esomeprazole',
    'prilosec': 'omeprazole',
    'prevacid': 'lansoprazole',
    'aciphex': 'rabeprazole',
    'protonix': 'pantoprazole',
    'dexilant': 'dexlansoprazole',
    'nexium_24hr': 'esomeprazole_strontium',

    // Respiratory
    'singulair': 'montelukast',
    'flovent': 'fluticasone',
    'advair': 'fluticasone_salmeterol',
    'clarinex': 'desloratadine',
    'allegra': 'fexofenadine',
    'accolate': 'zafirlukast',

    // Pain/Inflammation
    'celebrex': 'celecoxib',
    'vioxx': 'rofecoxib',
    'bextra': 'valdecoxib',
    'voltaren': 'diclofenac',
    'zyloprim': 'allopurinol',
    'colcrys': 'colchicine',
    'benemid': 'probenecid',
    'trexall': 'methotrexate',
    'plaquenil': 'hydroxychloroquine',

    // Diabetes
    'avandia': 'rosiglitazone',
    'actoplus': 'pioglitazone_metformin',
    'actos': 'pioglitazone',
    'glucophage': 'metformin',

    // CNS/Psychiatric
    'prozac': 'fluoxetine',
    'zoloft': 'sertraline',
    'paxil': 'paroxetine',
    'neurontin': 'gabapentin',
    'lyrica': 'pregabalin',

    // Antibiotics
    'augmentin': 'amoxicillin_clavulanate',
    'zithromax': 'azithromycin',
    'biaxin': 'clarithromycin',
    'amoxil': 'amoxicillin',
    'cipro': 'ciprofloxacin',
    'levaquin': 'levofloxacin',
    'vibramycin': 'doxycycline',
    'minocin': 'minocycline',
    'ceftin': 'cefuroxime',
    'duricef': 'cefadroxil',
    'vantin': 'cefpodoxime',

    // Other common medicines
    'viagra': 'sildenafil',
    'advil': 'ibuprofen',
    'tylenol': 'acetaminophen',
    'coumadin': 'warfarin',
    'lanoxin': 'digoxin',
    'lasix': 'furosemide',
    'aldactone': 'spironolactone',
    'dilantin': 'phenytoin',
    'microzide': 'hydrochlorothiazide',
    'deltasone': 'prednisone',
    'vicodin': 'hydrocodone_acetaminophen',
    'oxycontin': 'oxycodone',
    'bayer': 'aspirin',
  };

  /// Find generic alternatives for a list of medicine names
  Future<List<Map<String, dynamic>>> findGenericAlternatives(
    List<String> medicineNames
  ) async {
    List<Map<String, dynamic>> allAlternatives = [];

    for (String medicineName in medicineNames) {
      final alternatives = await _findAlternativesForMedicine(medicineName);
      if (alternatives.isNotEmpty) {
        allAlternatives.addAll(alternatives);
      }
    }

    return allAlternatives;
  }

  /// Find alternatives for a single medicine
  Future<List<Map<String, dynamic>>> _findAlternativesForMedicine(
    String medicineName
  ) async {
    final normalizedName = medicineName.toLowerCase().trim();

    // First, try direct mapping in Indian pharma database
    if (_indianGenericMappings.containsKey(normalizedName)) {
      return _indianGenericMappings[normalizedName]!
          .map((alt) => {
                ...alt,
                'original_medicine': medicineName,
                'brand_name': alt['brand'] ?? medicineName,
                'generic_name': alt['name'],
              })
          .toList();
    }

    // Try brand-to-generic mapping for Indian pharma
    final genericBase = _brandToGeneric[normalizedName];
    if (genericBase != null && _indianGenericMappings.containsKey(genericBase)) {
      return _indianGenericMappings[genericBase]!
          .map((alt) => {
                ...alt,
                'original_medicine': medicineName,
                'brand_name': medicineName,
                'generic_name': alt['name'],
              })
          .toList();
    }

    // Fallback to legacy mappings
    if (_genericMappings.containsKey(normalizedName)) {
      return _genericMappings[normalizedName]!
          .map((alt) => {
                ...alt,
                'original_medicine': medicineName,
                'brand_name': medicineName,
                'generic_name': alt['name'],
              })
          .toList();
    }

    // Try fuzzy matching for common variations in Indian pharma database
    final fuzzyMatch = _findFuzzyMatch(normalizedName);
    if (fuzzyMatch != null && _indianGenericMappings.containsKey(fuzzyMatch)) {
      return _indianGenericMappings[fuzzyMatch]!
          .map((alt) => {
                ...alt,
                'original_medicine': medicineName,
                'brand_name': medicineName,
                'generic_name': alt['name'],
              })
          .toList();
    }

    // Check database for custom mappings (if implemented)
    try {
      final dbResults = await _client
          .from('medicine_generics')
          .select('*')
          .eq('brand_name', normalizedName)
          .limit(10); // Increased limit for more results

      if (dbResults.isNotEmpty) {
        return dbResults.map((result) => {
              'name': result['generic_name'],
              'strength': result['strength'] ?? 'Standard',
              'savings': result['savings_percent'] ?? 70,
              'manufacturer': result['manufacturer'] ?? 'Indian Generic',
              'original_medicine': medicineName,
              'brand_name': medicineName,
              'generic_name': result['generic_name'],
            }).toList();
      }
    } catch (e) {
      // Database not available or table doesn't exist
      print('Database generic lookup failed: $e');
    }

    return [];
  }

  /// Fuzzy matching for medicine names
  String? _findFuzzyMatch(String medicineName) {
    // Simple fuzzy matching - in production, use more sophisticated algorithms
    // First check Indian pharma database
    for (String key in _indianGenericMappings.keys) {
      if (medicineName.contains(key) || key.contains(medicineName)) {
        return key;
      }
    }

    // Then check legacy mappings
    for (String key in _genericMappings.keys) {
      if (medicineName.contains(key) || key.contains(medicineName)) {
        return key;
      }
    }
    return null;
  }

  /// Get medicine details from database
  Future<Map<String, dynamic>?> getMedicineDetails(String medicineName) async {
    try {
      final results = await _client
          .from('medicines')
          .select('*')
          .ilike('name', '%$medicineName%')
          .limit(1);

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error fetching medicine details: $e');
      return null;
    }
  }

  /// Calculate potential savings
  Map<String, dynamic> calculateSavings(
    List<Map<String, dynamic>> alternatives,
    double originalPrice
  ) {
    if (alternatives.isEmpty) return {'total_savings': 0.0, 'best_alternative': null};

    double maxSavings = 0;
    Map<String, dynamic>? bestAlternative;

    for (var alt in alternatives) {
      final savingsPercent = alt['savings'] / 100.0;
      final savingsAmount = originalPrice * savingsPercent;

      if (savingsAmount > maxSavings) {
        maxSavings = savingsAmount;
        bestAlternative = alt;
      }
    }

    return {
      'total_savings': maxSavings,
      'best_alternative': bestAlternative,
      'savings_percentage': maxSavings > 0 ? (maxSavings / originalPrice * 100) : 0,
    };
  }

  /// Get AI recommendations with confidence scores
  Future<List<Map<String, dynamic>>> getAIRecommendations(
    List<String> medicines,
    {bool includePricing = true}
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    for (String medicine in medicines) {
      final alternatives = await _findAlternativesForMedicine(medicine);

      if (alternatives.isNotEmpty) {
        // Calculate confidence based on data quality
        final confidence = _calculateConfidence(alternatives);

        recommendations.add({
          'medicine': medicine,
          'alternatives': alternatives,
          'confidence_score': confidence,
          'recommendation_type': 'generic_alternative',
          'potential_savings': alternatives.isNotEmpty
              ? '${alternatives.first['savings']}%'
              : '0%',
        });
      }
    }

    return recommendations;
  }

  /// Calculate confidence score for recommendations
  double _calculateConfidence(List<Map<String, dynamic>> alternatives) {
    if (alternatives.isEmpty) return 0.0;

    // Simple confidence calculation based on number of alternatives and data quality
    final baseConfidence = alternatives.length >= 2 ? 0.9 : 0.7;

    // Adjust based on manufacturer diversity
    final manufacturers = alternatives.map((a) => a['manufacturer']).toSet();
    final manufacturerBonus = manufacturers.length > 1 ? 0.1 : 0.0;

    return (baseConfidence + manufacturerBonus).clamp(0.0, 1.0);
  }
}
