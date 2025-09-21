import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';
import '../../models/medication.dart';
import 'user_management_screen.dart';
import 'medication_management_screen.dart';
import 'medication_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<User> users = [];
  User? selectedUser;
  List<Medication> activeMedications = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final loadedUsers = await dbHelper.getUsers();
    setState(() {
      users = loadedUsers;
      if (users.isNotEmpty) {
        if (selectedUser != null && selectedUser!.id != null) {
          final updatedUser = users.firstWhere(
            (user) => user.id == selectedUser!.id,
            orElse: () => users.first,
          );
          selectedUser = updatedUser;
        } else {
          selectedUser = users.first;
        }
        _loadMedications();
      } else {
        selectedUser = null;
        isLoading = false;
      }
    });
  }

  Future<void> _loadMedications() async {
    print('_loadMedications called - selectedUser: ${selectedUser?.name}');
    if (selectedUser != null) {
      print('Loading medications for user ID: ${selectedUser!.id}');
      final loadedMedications = await dbHelper.getActiveMedicationsByUser(
        selectedUser!.id!,
      );
      print('Loaded ${loadedMedications.length} medications from database');
      for (var med in loadedMedications) {
        print('  - ${med.name}: ${med.quantity} ${med.unit}');
      }
      setState(() {
        activeMedications = loadedMedications;
        isLoading = false;
      });
      print('UI updated with ${activeMedications.length} medications');
    } else {
      print('No selected user, skipping medication load');
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    try {
      await dbHelper.deleteMedication(medication.id!);
      await _loadMedications(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medication.name} removido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover medicamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Medication medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja remover "${medication.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMedication(medication);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        title: const Text('Meus Medicamentos'),
        actions: [
          Center(
            child: DropdownButton<User>(
              value: selectedUser,
              icon: const SizedBox.shrink(),
              underline: Container(),
              onChanged: (User? newUser) {
                setState(() {
                  selectedUser = newUser;
                  _loadMedications();
                });
              },
              menuMaxHeight: MediaQuery.of(context).size.height * 0.75,
              items: users.map<DropdownMenuItem<User>>((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text(
                    user.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return users.map<Widget>((User user) {
                  return Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          Center(
            child: IconButton(
              icon: const Icon(Icons.manage_accounts),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
                _loadUsers();
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(
              child: Text(
                'Nenhum usuário cadastrado. Adicione um para começar!',
              ),
            )
          : activeMedications.isEmpty
          ? const Center(
              child: Text('Nenhum medicamento ativo para este usuário.'),
            )
          : ListView.builder(
              itemCount: activeMedications.length,
              itemBuilder: (context, index) {
                final medication = activeMedications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MedicationDetailsScreen(
                            medication: medication,
                          ),
                        ),
                      );
                      // Refresh medication list when returning from details screen
                      _loadMedications();
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  medication.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () => _editMedication(medication),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _showDeleteConfirmation(medication),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Dosagem: ${medication.quantity} ${medication.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Frequência: ${medication.frequency}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF286afb),
                                size: 18,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'Próxima dose: ${medication.firstDoseTime}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF286afb),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: users.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MedicationManagementScreen(
                      selectedUser: selectedUser,
                    ),
                  ),
                );
                // Refresh medications when returning from add screen
                _loadMedications();
              },
              backgroundColor: const Color(0xFF286afb),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  void _editMedication(Medication medication) async {
    print('Starting edit for medication: ${medication.name}');
    print('Before edit - current medications count: ${activeMedications.length}');
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicationManagementScreen(
          medicationToEdit: medication,
        ),
      ),
    );
    
    print('Returned from edit screen, refreshing medications...');
    await _loadMedications();
    print('After refresh - medications count: ${activeMedications.length}');
    
    // Force UI rebuild
    if (mounted) {
      setState(() {});
      print('UI rebuild triggered');
    }
  }
}
