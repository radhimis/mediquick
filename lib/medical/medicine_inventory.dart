import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import './add_medicine_page.dart';

class MedicineInventoryPage extends StatefulWidget {
  @override
  _MedicineInventoryPageState createState() => _MedicineInventoryPageState();
}

class _MedicineInventoryPageState extends State<MedicineInventoryPage> {
  List<Map<String, dynamic>> medicines = [];
  List<Map<String, dynamic>> filteredMedicines = [];
  bool _isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'All';
  String sortBy = 'name';
  bool ascending = true;
  bool _isSelectionMode = false;
  Set<String> selectedMedicineIds = {};

  // Available categories
  final List<String> categories = [
    'All',
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
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('medicines')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        medicines = List<Map<String, dynamic>>.from(data);
        _filterMedicines();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading medicines: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicinePage()),
    );

    if (result == true) {
      _loadMedicines(); // Reload the list
    }
  }

  void _editMedicine(Map<String, dynamic> medicine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicinePage(medicine: medicine)),
    );

    if (result == true) {
      _loadMedicines(); // Reload the list
    }
  }

  void _removeMedicine(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Medicine'),
        content: Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final client = Supabase.instance.client;
        await client.from('medicines').delete().eq('id', id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medicine deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _loadMedicines(); // Reload the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting medicine: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterMedicines() {
    List<Map<String, dynamic>> filtered = List.from(medicines);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((medicine) {
        final name = medicine['name']?.toString().toLowerCase() ?? '';
        final description = medicine['description']?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply category filter
    if (selectedCategory != 'All') {
      filtered = filtered.where((medicine) {
        final category = medicine['description']?.toString() ?? 'Other';
        return category == selectedCategory;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortBy) {
        case 'name':
          aValue = a['name']?.toString() ?? '';
          bValue = b['name']?.toString() ?? '';
          break;
        case 'price':
          aValue = a['price'] != null ? (a['price'] is num ? a['price'] : double.tryParse(a['price'].toString()) ?? 0.0) : 0.0;
          bValue = b['price'] != null ? (b['price'] is num ? b['price'] : double.tryParse(b['price'].toString()) ?? 0.0) : 0.0;
          break;
        case 'stock':
          aValue = a['stock_quantity'] != null ? (a['stock_quantity'] is int ? a['stock_quantity'] : int.tryParse(a['stock_quantity'].toString()) ?? 0) : 0;
          bValue = b['stock_quantity'] != null ? (b['stock_quantity'] is int ? b['stock_quantity'] : int.tryParse(b['stock_quantity'].toString()) ?? 0) : 0;
          break;
        case 'expiry':
          aValue = a['expiry_date'] != null ? DateTime.tryParse(a['expiry_date'].toString()) ?? DateTime(2099) : DateTime(2099);
          bValue = b['expiry_date'] != null ? DateTime.tryParse(b['expiry_date'].toString()) ?? DateTime(2099) : DateTime(2099);
          break;
        default:
          aValue = a['name']?.toString() ?? '';
          bValue = b['name']?.toString() ?? '';
      }

      if (ascending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });

    setState(() {
      filteredMedicines = filtered;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        selectedMedicineIds.clear();
      }
    });
  }

  void _toggleMedicineSelection(String id) {
    setState(() {
      if (selectedMedicineIds.contains(id)) {
        selectedMedicineIds.remove(id);
      } else {
        selectedMedicineIds.add(id);
      }
    });
  }

  void _selectAllMedicines() {
    setState(() {
      if (selectedMedicineIds.length == filteredMedicines.length) {
        selectedMedicineIds.clear();
      } else {
        selectedMedicineIds = filteredMedicines.map((m) => m['id'].toString()).toSet();
      }
    });
  }

  Future<void> _bulkDeleteMedicines() async {
    if (selectedMedicineIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Delete Medicines'),
        content: Text('Are you sure you want to delete ${selectedMedicineIds.length} medicines?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final client = Supabase.instance.client;
        for (var id in selectedMedicineIds) {
          await client.from('medicines').delete().eq('id', id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedMedicineIds.length} medicines deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isSelectionMode = false;
          selectedMedicineIds.clear();
        });
        _loadMedicines();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting medicines: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkUpdateStock() async {
    if (selectedMedicineIds.isEmpty) return;

    final stockController = TextEditingController();
    final operation = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update stock for ${selectedMedicineIds.length} medicines'),
            SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('set'),
            child: Text('Set Stock'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('add'),
            child: Text('Add to Stock'),
          ),
        ],
      ),
    );

    if (operation != null && stockController.text.isNotEmpty) {
      final stockValue = int.tryParse(stockController.text);
      if (stockValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid stock quantity'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final client = Supabase.instance.client;
        if (operation == 'set') {
          for (var id in selectedMedicineIds) {
            await client.from('medicines').update({'stock_quantity': stockValue}).eq('id', id);
          }
        } else if (operation == 'add') {
          // For add operation, we need to get current values and update
          final currentMedicines = medicines.where((m) => selectedMedicineIds.contains(m['id'].toString())).toList();
          for (final medicine in currentMedicines) {
            final currentStock = medicine['stock_quantity'] ?? 0;
            final newStock = (currentStock is int ? currentStock : int.tryParse(currentStock.toString()) ?? 0) + stockValue;
            await client.from('medicines').update({'stock_quantity': newStock}).eq('id', medicine['id']);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isSelectionMode = false;
          selectedMedicineIds.clear();
        });
        _loadMedicines();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating stock: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = result.files.first;
        final csvString = String.fromCharCodes(file.bytes!);
        final csvTable = CsvToListConverter().convert(csvString);

        if (csvTable.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV file is empty'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Assume first row is headers
        final headers = csvTable[0].map((e) => e.toString().toLowerCase()).toList();
        final dataRows = csvTable.sublist(1);

        // Validate headers
        final requiredHeaders = ['name', 'price', 'stock_quantity'];
        final missingHeaders = requiredHeaders.where((h) => !headers.contains(h)).toList();

        if (missingHeaders.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Missing required columns: ${missingHeaders.join(", ")}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final client = Supabase.instance.client;
        int successCount = 0;
        int errorCount = 0;

        for (final row in dataRows) {
          try {
            final medicineData = <String, dynamic>{};
            
            for (int i = 0; i < headers.length && i < row.length; i++) {
              final header = headers[i];
              final value = row[i];
              
              if (header == 'price') {
                medicineData[header] = double.tryParse(value.toString()) ?? 0.0;
              } else if (header == 'stock_quantity') {
                medicineData[header] = int.tryParse(value.toString()) ?? 0;
              } else {
                medicineData[header] = value.toString();
              }
            }

            // Set default category if not provided
            if (!medicineData.containsKey('description') || medicineData['description'].isEmpty) {
              medicineData['description'] = 'Other';
            }

            await client.from('medicines').insert(medicineData);
            successCount++;
          } catch (e) {
            errorCount++;
            print('Error importing row: $e');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import completed: $successCount successful, $errorCount failed'),
            backgroundColor: successCount > 0 ? Colors.green : Colors.red,
          ),
        );

        if (successCount > 0) {
          _loadMedicines();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing CSV: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Inventory'),
        backgroundColor: Color(0xFF1E90FF),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importFromCSV,
            tooltip: 'Import from CSV',
          ),
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
            onPressed: _toggleSelectionMode,
            tooltip: _isSelectionMode ? 'Exit Selection Mode' : 'Enter Selection Mode',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMedicines,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterMedicines();
              },
            ),
            SizedBox(height: 10),

            // Filter and Sort Row
            Row(
              children: [
                // Category Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                      _filterMedicines();
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Sort Options
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    value: sortBy,
                    items: [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                      DropdownMenuItem(value: 'stock', child: Text('Stock')),
                      DropdownMenuItem(value: 'expiry', child: Text('Expiry')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortBy = value!;
                      });
                      _filterMedicines();
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Sort Direction
                IconButton(
                  icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                    _filterMedicines();
                  },
                  tooltip: ascending ? 'Sort Ascending' : 'Sort Descending',
                ),
              ],
            ),
            SizedBox(height: 10),

            // Results Count
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Showing ${filteredMedicines.length} of ${medicines.length} medicines',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            SizedBox(height: 10),

            // Bulk Actions (when in selection mode)
            if (_isSelectionMode) ...[
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _selectAllMedicines,
                    icon: Icon(selectedMedicineIds.length == filteredMedicines.length ? Icons.check_box : Icons.check_box_outline_blank),
                    label: Text(selectedMedicineIds.length == filteredMedicines.length ? 'Deselect All' : 'Select All'),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: selectedMedicineIds.isNotEmpty ? _bulkUpdateStock : null,
                    icon: Icon(Icons.edit),
                    label: Text('Update Stock (${selectedMedicineIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: selectedMedicineIds.isNotEmpty ? _bulkDeleteMedicines : null,
                    icon: Icon(Icons.delete),
                    label: Text('Delete (${selectedMedicineIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ] else ...[
              ElevatedButton(
                onPressed: _addMedicine,
                child: Text('Add New Medicine'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E90FF),
                ),
              ),
              SizedBox(height: 20),
            ],
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredMedicines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No medicines found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                searchQuery.isNotEmpty || selectedCategory != 'All'
                                    ? 'Try adjusting your search or filters'
                                    : 'Add your first medicine to get started',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = filteredMedicines[index];
                            final stockQty = medicine['stock_quantity'];
                            final isLowStock = stockQty != null ? (stockQty is int ? stockQty < 10 : (int.tryParse(stockQty.toString()) ?? 0) < 10) : false;
                            final expiryDate = medicine['expiry_date'];
                            final isExpired = expiryDate != null && DateTime.tryParse(expiryDate.toString())?.isBefore(DateTime.now()) == true;
                            final medicineId = medicine['id'].toString();
                            final isSelected = selectedMedicineIds.contains(medicineId);
                            return Card(
                              color: isExpired
                                  ? Colors.red[100]
                                  : (isLowStock ? Colors.yellow[100] : Colors.white),
                              child: ListTile(
                                leading: _isSelectionMode
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (value) => _toggleMedicineSelection(medicineId),
                                      )
                                    : null,
                                title: Text(medicine['name'] ?? 'Unknown'),
                                subtitle: Text(
                                  'Price: ₹${medicine['price'] != null ? (medicine['price'] is num ? medicine['price'] : double.tryParse(medicine['price'].toString()) ?? 0.0) : 'N/A'} | Qty: ${stockQty != null ? (stockQty is int ? stockQty : int.tryParse(stockQty.toString()) ?? 0) : 0} | Expiry: ${medicine['expiry_date'] ?? 'N/A'} | Category: ${medicine['description'] ?? 'Other'}',
                                ),
                                trailing: _isSelectionMode
                                    ? null
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () => _editMedicine(medicine),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _removeMedicine(medicine['id']),
                                          ),
                                        ],
                                      ),
                                onTap: _isSelectionMode
                                    ? () => _toggleMedicineSelection(medicineId)
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
