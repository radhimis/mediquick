import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ---------------- MyApp ----------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Interactive Doctor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Dashboard(),
    );
  }
}

// ---------------- Data Models (for demo) ----------------
class Doctor {
  String name;
  String specialization;
  String email;
  String contact;
  String profileImage;

  Doctor({
    required this.name,
    required this.specialization,
    required this.email,
    required this.contact,
    required this.profileImage,
  });
}

// ---------------- Home Page ----------------
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo stats
    int totalPatients = 25;
    int totalMedicines = 18;
    int upcomingAppointments = 5;
    int pendingAppointments = 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Dr. Aarth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(title: 'Patients', count: totalPatients, color: Colors.blue),
                SummaryCard(title: 'Medicines', count: totalMedicines, color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(title: 'Upcoming Appts', count: upcomingAppointments, color: Colors.orange),
                SummaryCard(title: 'Pending Appts', count: pendingAppointments, color: Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Add Patient',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPatientPage()));
                  },
                  color: Colors.blue,
                ),
                QuickActionButton(
                  icon: Icons.medical_services,
                  label: 'Add Medicine',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicinePage()));
                  },
                  color: Colors.green,
                ),
                QuickActionButton(
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsTab()));
                  },
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}

// ---------------- Summary Card ----------------
class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const SummaryCard({super.key, required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2))],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------- Quick Action Button ----------------
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const QuickActionButton({super.key, required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ---------------- Bottom Navigation Bar ----------------
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const Dashboard()));
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientsTab()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicinesTab()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsTab()));
        if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileTab()));
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Medicines'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
      ],
    );
  }
}

// ---------------- Patients Tab ----------------
class PatientsTab extends StatelessWidget {
  const PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = [
      {'name': 'John Doe', 'age': '30', 'condition': 'Diabetes'},
      {'name': 'Jane Smith', 'age': '25', 'condition': 'Asthma'},
      {'name': 'Mark Wilson', 'age': '40', 'condition': 'Hypertension'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              title: Text(patient['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Age: ${patient['age']} | Condition: ${patient['condition']}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Add Patient Page ----------------
class AddPatientPage extends StatelessWidget {
  const AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final conditionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Age')),
            TextField(controller: conditionController, decoration: const InputDecoration(labelText: 'Condition')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add logic here
                Navigator.pop(context);
              },
              child: const Text('Save Patient'),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- Medicines Tab ----------------
class MedicinesTab extends StatelessWidget {
  const MedicinesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final medicines = [
      {'name': 'Paracetamol', 'dosage': '500mg'},
      {'name': 'Insulin', 'dosage': '10 units'},
      {'name': 'Aspirin', 'dosage': '75mg'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Medicines')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final med = medicines[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              title: Text(med['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Dosage: ${med['dosage']}'),
              trailing: const Icon(Icons.edit),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Add Medicine Page ----------------
class AddMedicinePage extends StatelessWidget {
  const AddMedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'Dosage')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add logic here
                Navigator.pop(context);
              },
              child: const Text('Save Medicine'),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- Appointments Tab ----------------
class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final upcoming = [
      {'patient': 'John Doe', 'time': '10:00 AM'},
      {'patient': 'Jane Smith', 'time': '11:00 AM'},
    ];
    final pending = [
      {'patient': 'Mark Wilson', 'time': '2:00 PM'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...upcoming.map((a) => Card(
              child: ListTile(
                title: Text(a['patient']!),
                subtitle: Text(a['time']!),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            )),
            const SizedBox(height: 16),
            const Text('Pending', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...pending.map((a) => Card(
              child: ListTile(
                title: Text(a['patient']!),
                subtitle: Text(a['time']!),
                trailing: const Icon(Icons.pending, color: Colors.orange),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ---------------- Profile Tab ----------------
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Doctor doctor = Doctor(
    name: 'Dr. Aarth Mistry',
    specialization: 'Cardiologist',
    email: 'aarth@example.com',
    contact: '+91 9876543210',
    profileImage: 'https://via.placeholder.com/150',
  );

  void _editProfile() {
    final nameController = TextEditingController(text: doctor.name);
    final specializationController = TextEditingController(text: doctor.specialization);
    final emailController = TextEditingController(text: doctor.email);
    final contactController = TextEditingController(text: doctor.contact);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: specializationController, decoration: const InputDecoration(labelText: 'Specialization')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                doctor.name = nameController.text;
                doctor.specialization = specializationController.text;
                doctor.email = emailController.text;
                doctor.contact = contactController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Change profile picture logic
              },
              child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(doctor.profileImage)),
            ),
            const SizedBox(height: 16),
            Text(doctor.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(doctor.specialization, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Email: ${doctor.email}'),
            Text('Contact: ${doctor.contact}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _editProfile, icon: const Icon(Icons.edit), label: const Text('Edit Profile')),
            const SizedBox(height: 24),
            const Text('Stats Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SummaryCard(title: 'Patients Seen', count: 5, color: Colors.blue),
                SummaryCard(title: 'Appointments', count: 3, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
