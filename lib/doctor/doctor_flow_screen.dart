import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorFlowScreen extends StatefulWidget {
  const DoctorFlowScreen({Key? key}) : super(key: key);

  @override
  State<DoctorFlowScreen> createState() => _DoctorFlowScreenState();
}

class _DoctorFlowScreenState extends State<DoctorFlowScreen> {
  int _screenIndex = 0;

  final List<Widget> _screens = const [
    PrescriptionGeneratorScreen(),
    AppointmentsScreen(),
  ];

  void _nextScreen() {
    setState(() {
      _screenIndex = (_screenIndex + 1) % _screens.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_screenIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA084CA),
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _nextScreen,
          child: const Text('Next'),
        ),
      ),
    );
  }
}

// ---------------- PRESCRIPTION SCREEN ----------------

class PrescriptionGeneratorScreen extends StatefulWidget {
  const PrescriptionGeneratorScreen({Key? key}) : super(key: key);

  @override
  _PrescriptionGeneratorScreenState createState() =>
      _PrescriptionGeneratorScreenState();
}

class _PrescriptionGeneratorScreenState
    extends State<PrescriptionGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, String>> recentPrescriptions = [];

  void _sendPrescription() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        recentPrescriptions.add({
          'patient': _patientController.text,
          'medicine': _medicineNameController.text,
          'date': DateTime.now().toString().substring(0, 10),
        });

        _patientController.clear();
        _medicineNameController.clear();
        _dosageController.clear();
        _frequencyController.clear();
        _durationController.clear();
        _notesController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription sent successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Generator'),
        backgroundColor: const Color(0xFFA084CA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Patient',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _patientController,
                decoration: const InputDecoration(
                    hintText: 'Enter patient name',
                    border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a patient name' : null,
              ),
              const SizedBox(height: 16),
              const Text('Prescription Form',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicineNameController,
                decoration: const InputDecoration(
                    labelText: 'Medicine Name', border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Please enter medicine name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                    labelText: 'Dosage', border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Please enter dosage' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                    labelText: 'Frequency', border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Please enter frequency' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                    labelText: 'Duration', border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Please enter duration' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Additional Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendPrescription,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA084CA),
                    minimumSize: const Size(double.infinity, 48)),
                child: const Text('Send Prescription'),
              ),
              const SizedBox(height: 24),
              const Text('Recent Prescriptions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...recentPrescriptions.map((p) => ListTile(
                title: Text(p['patient']!),
                subtitle: Text('${p['medicine']} - ${p['date']}'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- APPOINTMENTS SCREEN ----------------

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, String>> appointments = [
    {
      'patient': 'John Doe',
      'datetime': '2025-08-13 09:00 AM',
      'type': 'In-Person',
      'status': 'Confirmed'
    },
    {
      'patient': 'Jane Smith',
      'datetime': '2025-08-12 11:00 AM',
      'type': 'Video',
      'status': 'Pending'
    },
  ];

  void _addAppointment(String name, String date, String type) {
    setState(() {
      appointments.add({
        'patient': name,
        'datetime': '$date 10:00 AM',
        'type': type,
        'status': 'Pending'
      });
    });
  }

  void _showAddAppointmentDialog() {
    final _nameCtrl = TextEditingController();
    String selectedType = 'In-Person';
    DateTime chosenDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Appointment'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Patient Name'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedType,
                onChanged: (val) {
                  setState(() {
                    selectedType = val!;
                  });
                },
                items: ['In-Person', 'Video']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: chosenDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );
                  if (picked != null) {
                    setState(() {
                      chosenDate = picked;
                    });
                  }
                },
                child: const Text('Pick Date'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.isNotEmpty) {
                  _addAppointment(
                      _nameCtrl.text,
                      '${chosenDate.toLocal()}'.split(' ')[0],
                      selectedType);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Appointments'),
          backgroundColor: const Color(0xFFA084CA)),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: const Color(0xFFA084CA), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple, shape: BoxShape.circle),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                DateTime? apptDate;
                try {
                  apptDate = DateTime.parse(appt['datetime']!.split(' ')[0]);
                } catch (_) {}

                final showIt = _selectedDay == null ||
                    (apptDate != null && isSameDay(_selectedDay, apptDate));
                if (!showIt) return const SizedBox.shrink();

                return Card(
                  child: ListTile(
                    title: Text(appt['patient']!),
                    subtitle: Text('${appt['datetime']} - ${appt['type']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (appt['status'] == 'Pending') ...[
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                appointments[index]['status'] = 'Confirmed';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Confirmed appointment for ${appt['patient']}')));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                appointments[index]['status'] = 'Declined';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Declined appointment for ${appt['patient']}')));
                            },
                          ),
                        ] else ...[
                          Text(appt['status']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddAppointmentDialog,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA084CA),
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Add Appointment'),
            ),
          )
        ],
      ),
    );
  }
}
