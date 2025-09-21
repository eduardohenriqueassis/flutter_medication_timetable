import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:medicationtimetable/models/user.dart';
import 'package:medicationtimetable/models/medication.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'medication_timetable.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Tabela de medicamentos
    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT NOT NULL,
        quantity REAL,
        unit TEXT,
        isContinuous INTEGER,
        startDate TEXT,
        endDate TEXT,
        frequency TEXT,
        firstDoseTime TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // Retorna uma lista de objetos User
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Insere um novo usuário a partir de um objeto User
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // Atualiza um usuário a partir de um objeto User
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Exclui um usuário pelo seu ID
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Retorna uma lista de objetos Medication para os medicamentos ativos de um usuário
  Future<List<Medication>> getActiveMedicationsByUser(int userId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneDayInMillis = 24 * 60 * 60 * 1000;

    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'userId = ? AND (isContinuous = 1 OR endDate >= ?)',
      whereArgs: [userId, (now - oneDayInMillis)],
    );

    return List.generate(maps.length, (i) {
      return Medication.fromMap(maps[i]);
    });
  }

  // Retorna uma lista de objetos Medication para os medicamentos concluídos de um usuário
  Future<List<Medication>> getCompletedMedicationsByUser(int userId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneDayInMillis = 24 * 60 * 60 * 1000;

    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'userId = ? AND isContinuous = 0 AND endDate < ?',
      whereArgs: [userId, (now - oneDayInMillis)],
    );

    return List.generate(maps.length, (i) {
      return Medication.fromMap(maps[i]);
    });
  }

  // Insere um novo medicamento a partir de um objeto Medication
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert('medications', medication.toMap());
  }

  // Atualiza um medicamento a partir de um objeto Medication
  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  // Exclui um medicamento pelo seu ID
  Future<int> deleteMedication(int id) async {
    final db = await database;
    return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // Busca um medicamento pelo seu ID
  Future<Medication?> getMedicationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Medication.fromMap(maps.first);
    }
    return null;
  }
}
