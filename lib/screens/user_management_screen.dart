import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Diálogo para editar um usuário
  void _showEditUserDialog(User user) {
    TextEditingController nameController = TextEditingController(
      text: user.name,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Usuário'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Novo nome do usuário'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _updateUser(user.id!, nameController.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Método para atualizar o nome do usuário
  Future<void> _updateUser(int userId, String newName) async {
    final updatedUser = User(id: userId, name: newName);
    await dbHelper.updateUser(updatedUser);
    await _loadUsers(); // Recarrega a lista após a atualização
  }

  Future<void> _loadUsers() async {
    final loadedUsers = await dbHelper.getUsers();
    setState(() {
      users = loadedUsers;
      isLoading = false;
    });
  }

  Future<void> _addUser(String name) async {
    final newUser = User(name: name);
    await dbHelper.insertUser(newUser);
    await _loadUsers();
  }

  Future<void> _deleteUser(int userId) async {
    await dbHelper.deleteUser(userId);
    await _loadUsers(); // Recarrega a lista após a exclusão
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('Nenhum usuário cadastrado.'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {
                          _showEditUserDialog(user);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteUser(user.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog();
        },
        backgroundColor: const Color(0xFF286afb),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  // Diálogo para adicionar novo usuário
  void _showAddUserDialog() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Usuário'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nome do usuário'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addUser(nameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}
