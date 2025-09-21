// medication_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/timer_picker_dropdown.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../models/medication.dart';
import 'user_management_screen.dart';

class MedicationManagementScreen extends StatefulWidget {
  final User? selectedUser;
  final Medication? medicationToEdit;

  const MedicationManagementScreen({
    Key? key,
    this.selectedUser,
    this.medicationToEdit,
  }) : super(key: key);

  @override
  _MedicationManagementScreenState createState() =>
      _MedicationManagementScreenState();
}

class _MedicationManagementScreenState
    extends State<MedicationManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timePickerKey = GlobalKey<TimePickerDropdownState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _daysController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _selectedUnit = 'mg';
  String _selectedFrequency = '1x por dia';
  DateTime _startDate = DateTime.now();
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool get _isEditing => widget.medicationToEdit != null;
  int? _initialHour;
  int? _initialMinute;

  bool get isFormComplete {
    return _nameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _daysController.text.isNotEmpty &&
        _selectedUser != null &&
        _timePickerKey.currentState?.isTimeSelected == true;
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();

    // Add listeners to text controllers to update UI when text changes
    _nameController.addListener(() => setState(() {}));
    _quantityController.addListener(() => setState(() {}));
    _daysController.addListener(() => setState(() {}));

    // If editing, populate form with existing medication data
    if (_isEditing) {
      _populateFormWithExistingData();
    }
  }

  void _populateFormWithExistingData() {
    final medication = widget.medicationToEdit!;

    // Populate text fields
    _nameController.text = medication.name;
    _quantityController.text = medication.quantity.toString();

    // Calculate days from start and end date
    final startDate = DateTime.parse(medication.startDate);
    final endDate = medication.endDate != null
        ? DateTime.parse(medication.endDate!)
        : DateTime.now();
    final days = endDate.difference(startDate).inDays + 1;
    _daysController.text = days.toString();

    // Set other values
    _selectedUnit = medication.unit;
    _selectedFrequency = medication.frequency;
    _startDate = startDate;

    // Parse first dose time and store for later use
    final timeParts = medication.firstDoseTime.split(':');
    _initialHour = int.parse(timeParts[0]);
    _initialMinute = int.parse(timeParts[1]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getUsers();
    setState(() {
      _users = users;
      if (users.isNotEmpty) {
        // Pre-select the passed user if it exists in the list, otherwise select first user
        if (widget.selectedUser != null) {
          final foundUser = users.firstWhere(
            (user) => user.id == widget.selectedUser!.id,
            orElse: () => users.first,
          );
          _selectedUser = foundUser;
        } else {
          _selectedUser = users.first;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveMedication() async {
    // Get time from TimePickerDropdown
    final timePickerState = _timePickerKey.currentState;
    if (timePickerState == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Calculate end date
      final days = int.parse(_daysController.text);
      final endDate = _startDate.add(
        Duration(days: days - 1),
      ); // -1 because start date counts as day 1

      // Create medication object
      final medication = Medication(
        id: _isEditing
            ? widget.medicationToEdit!.id
            : null, // Keep existing ID when editing
        userId: _selectedUser!.id!,
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        isContinuous: false, // Based on days, not continuous
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
        frequency: _selectedFrequency,
        firstDoseTime:
            '${timePickerState.selectedHour.toString().padLeft(2, '0')}:${timePickerState.selectedMinute.toString().padLeft(2, '0')}',
      );

      // Save or update to database
      if (_isEditing) {
        print(
          'Updating medication: ${medication.name} with ID: ${medication.id}',
        );
        final result = await _dbHelper.updateMedication(medication);
        print('Update result: $result rows affected');
      } else {
        print('Inserting new medication: ${medication.name}');
        final result = await _dbHelper.insertMedication(medication);
        print('Insert result: $result');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Medicamento atualizado com sucesso!'
                  : 'Medicamento salvo com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao ${_isEditing ? 'atualizar' : 'salvar'} medicamento: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Função para mostrar o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Medicamento' : 'Adicionar Medicamento',
        ),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 24),
                    Text(
                      'Nenhum usuário cadastrado',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Você precisa cadastrar pelo menos um usuário antes de adicionar medicamentos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UserManagementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Gerenciar Usuários'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF286afb),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 42.0,
                bottom: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Medicamento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // User selector dropdown
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<User>(
                          isExpanded: true,
                          value: _selectedUser,
                          items: _users.map<DropdownMenuItem<User>>((
                            User user,
                          ) {
                            return DropdownMenuItem<User>(
                              value: user,
                              child: Text(user.name),
                            );
                          }).toList(),
                          onChanged: (User? newUser) {
                            setState(() {
                              _selectedUser = newUser;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Dosagem',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 12.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: SizedBox(
                            height: 56, // Fixed height to match TextFormField
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Unidade',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5.0,
                                  horizontal: 12.0,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedUnit,
                                  items:
                                      <String>[
                                        'mg',
                                        'g',
                                        'ml',
                                        'comprimidos',
                                        'gotas',
                                        'ampolas',
                                        'supositórios',
                                      ].map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedUnit = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Nova Row para a data inicial e a janela de horas
                    TimePickerDropdown(
                      key: _timePickerKey,
                      onChanged: () => setState(() {}),
                      initialHour: _initialHour,
                      initialMinute: _initialMinute,
                    ),
                    const SizedBox(height: 16.0),
                    // Frequency dropdown
                    SizedBox(
                      height: 56, // Fixed height to match TextFormField
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Frequência',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 12.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedFrequency,
                            items: const [
                              DropdownMenuItem<String>(
                                value: '1x por dia',
                                child: Text('1x por dia'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'A cada 2 horas',
                                child: Text('A cada 2 horas'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'A cada 4 horas',
                                child: Text('A cada 4 horas'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'A cada 6 horas',
                                child: Text('A cada 6 horas'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'A cada 8 horas',
                                child: Text('A cada 8 horas'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'A cada 12 horas',
                                child: Text('A cada 12 horas'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFrequency = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Quantidade de dias',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 12.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: DateFormat('dd/MM/yyyy').format(_startDate),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: const InputDecoration(
                              labelText: 'Data Inicial',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 12.0,
                              ),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 
                              MediaQuery.of(context).padding.top - 
                              kToolbarHeight - 
                              MediaQuery.of(context).padding.bottom - 
                              600 - 20, // Approximate height of all form fields + 20px bottom space
                    ),
                    const SizedBox(height: 36.0),
                    ElevatedButton(
                      onPressed: (_isSaving || !isFormComplete)
                          ? null
                          : _saveMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF286afb),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: _isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Salvando...',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            )
                          : Text(
                              _isEditing
                                  ? 'Atualizar Medicamento'
                                  : 'Salvar Medicamento',
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
