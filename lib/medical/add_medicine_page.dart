import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMedicinePage extends StatefulWidget {
  final Map<String, dynamic>? medicine; // For editing existing medicine

  const AddMedicinePage({super.key, this.medicine});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _expiryController = TextEditingController();
  String _selectedCategory = 'Other';
  bool _isLoading = false;

  // Available categories
  final List<String> categories = [
    'Pain Relief',
    'Antibiotics',
    'Vitamins',
    'Cardiovascular',
    'Respiratory',
    'Gastrointestinal',
    'Dermatology',
    'Neurology',
    'Endocrinology',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!['name'] ?? '';
      _stockController.text = widget.medicine!['stock_quantity']?.toString() ?? '';
      _selectedCategory = widget.medicine!['description'] ?? 'Other';
      if (widget.medicine!['expiry_date'] != null) {
        _expiryController.text = widget.medicine!['expiry_date'];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _expiryController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final medicineData = {
        'name': _nameController.text.trim(),
        'stock_quantity': int.parse(_stockController.text),
        'description': _selectedCategory,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only add expiry_date if it's provided
      if (_expiryController.text.isNotEmpty) {
        medicineData['expiry_date'] = _expiryController.text;
      }

      if (widget.medicine != null) {
        // Update existing medicine
        await client
            .from('medicines')
            .update(medicineData)
            .eq('id', widget.medicine!['id']);
      } else {
        // Add new medicine
        medicineData['created_at'] = DateTime.now().toIso8601String();
        await client.from('medicines').insert(medicineData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.medicine != null
              ? 'Medicine updated successfully!'
              : 'Medicine added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      print('Error saving medicine: $e'); // For debugging
      String errorMessage = 'Error saving medicine';

      // Provide more specific error messages
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check database policies.';
      } else if (e.toString().contains('table') && e.toString().contains('does not exist')) {
        errorMessage = 'Database table not found. Please run the setup SQL first.';
      } else if (e.toString().contains('duplicate')) {
        errorMessage = 'Medicine with this name already exists.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine != null ? 'Edit Medicine' : 'Add Medicine'),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () => _selectExpiryDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectExpiryDate(context),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E90FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.medicine != null ? 'Update Medicine' : 'Add Medicine',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}