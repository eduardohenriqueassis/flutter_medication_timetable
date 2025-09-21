import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import 'medication_management_screen.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final Medication medication;

  const MedicationDetailsScreen({
    Key? key,
    required this.medication,
  }) : super(key: key);

  @override
  _MedicationDetailsScreenState createState() => _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  late Medication _medication;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _medication = widget.medication;
  }

  Future<void> _refreshMedication() async {
    try {
      final updatedMedication = await _dbHelper.getMedicationById(_medication.id!);
      if (updatedMedication != null) {
        setState(() {
          _medication = updatedMedication;
        });
      }
    } catch (e) {
      print('Error refreshing medication: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_medication.name),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMedication(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Name Card
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medication,
                          color: Color(0xFF286afb),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _medication.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Dosage Information
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações da Dosagem',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _buildInfoRow('Quantidade', '${_medication.quantity} ${_medication.unit}'),
                    _buildInfoRow('Frequência', _medication.frequency),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Schedule Information
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cronograma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _buildInfoRow('Data de Início', _formatDate(_medication.startDate)),
                    if (_medication.endDate != null)
                      _buildInfoRow('Data de Término', _formatDate(_medication.endDate!)),
                    const SizedBox(height: 12.0),
                    _buildDoseTimesSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Treatment Duration
            if (_medication.endDate != null)
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duração do Tratamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      _buildDurationInfo(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationInfo() {
    if (_medication.endDate == null) return const SizedBox.shrink();

    final startDate = DateTime.parse(_medication.startDate);
    final endDate = DateTime.parse(_medication.endDate!);
    final duration = endDate.difference(startDate).inDays + 1; // +1 to include both start and end days

    return Row(
      children: [
        const Icon(
          Icons.schedule,
          color: Color(0xFF286afb),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$duration ${duration == 1 ? 'dia' : 'dias'} de tratamento',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF286afb),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDoseTimesSection() {
    final doseTimes = _calculateDoseTimes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horários das Doses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8.0),
        ...doseTimes.map((time) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF286afb),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<String> _calculateDoseTimes() {
    final startDate = DateTime.parse(_medication.startDate);
    final firstDoseTime = _medication.firstDoseTime.split(':');
    final hour = int.parse(firstDoseTime[0]);
    final minute = int.parse(firstDoseTime[1]);
    
    final firstDose = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      hour,
      minute,
    );

    final intervalHours = _getIntervalHours(_medication.frequency);
    final doseTimes = <String>[];
    
    // Calculate times for 24 hours from the first dose
    var currentTime = firstDose;
    final endTime = firstDose.add(const Duration(hours: 24));
    
    while (currentTime.isBefore(endTime)) {
      doseTimes.add(DateFormat('HH:mm').format(currentTime));
      currentTime = currentTime.add(Duration(hours: intervalHours));
    }

    return doseTimes;
  }

  int _getIntervalHours(String frequency) {
    switch (frequency) {
      case '1x por dia':
        return 24;
      case 'A cada 2 horas':
        return 2;
      case 'A cada 4 horas':
        return 4;
      case 'A cada 6 horas':
        return 6;
      case 'A cada 8 horas':
        return 8;
      case 'A cada 12 horas':
        return 12;
      default:
        return 24;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja remover "${_medication.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteMedication(context);
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

  Future<void> _deleteMedication(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteMedication(_medication.id!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_medication.name} removido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to home screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover medicamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editMedication(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicationManagementScreen(
          medicationToEdit: _medication,
        ),
      ),
    );
    // Refresh medication data when returning from edit
    await _refreshMedication();
  }
}
