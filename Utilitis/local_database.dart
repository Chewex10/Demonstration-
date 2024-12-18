import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../components/service_request_provider.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<void> insertOrUpdate(ServiceRequest request) async {
    final db = await instance.database;

    // Ensure we are updating the correct record if it exists
    final existingRequest = await readServiceRequest(request.id!);
    if (existingRequest != null) {
      // If the record exists, update it
      await db.update(
        tableServiceRequests,
        request.toJson(),
        where: '${ServiceRequestFields.id} = ?',
        whereArgs: [request.id],
      );
    } else {
      // If the record does not exist, insert it
      await db.insert(
        tableServiceRequests,
        request.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('service_requests.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Incremented the version number to match the schema upgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const textNotNullType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const timeType = 'TEXT NOT NULL';

    await db.execute(''' 
    CREATE TABLE $tableServiceRequests (
      ${ServiceRequestFields.id} $idType,
      ${ServiceRequestFields.userId} $textNotNullType,
      ${ServiceRequestFields.clientName} $textNotNullType,
      ${ServiceRequestFields.serviceDescription} $textNotNullType,
      ${ServiceRequestFields.date} $textNotNullType,
      ${ServiceRequestFields.time} $timeType,
      ${ServiceRequestFields.location} $textNotNullType,
      ${ServiceRequestFields.imagePath} $textNotNullType,
      ${ServiceRequestFields.isApproved} $boolType,
      ${ServiceRequestFields.status} $textNotNullType,
      ${ServiceRequestFields.category} $textNotNullType,
      ${ServiceRequestFields.phoneNumber} $textNotNullType,
      ${ServiceRequestFields.email} $textType,  -- Allow NULL for email field
      ${ServiceRequestFields.technicianId} $textNotNullType -- New field for technician ID
    )
  ''' );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute(''' 
        ALTER TABLE $tableServiceRequests ADD COLUMN ${ServiceRequestFields.technicianId} TEXT NOT NULL; 
      ''' );
    }
  }

  Future<ServiceRequest?> readServiceRequest(String id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableServiceRequests,
      columns: ServiceRequestFields.values,
      where: '${ServiceRequestFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ServiceRequest.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<ServiceRequest>> readAllServiceRequests(String userId) async {
    final db = await instance.database;

    final result = await db.query(
      tableServiceRequests,
      where: '${ServiceRequestFields.userId} = ?',
      whereArgs: [userId],
    );

    return result.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  Future<List<ServiceRequest>> readAllServiceRequestsForAdmin() async {
    final db = await instance.database;

    final result = await db.query(tableServiceRequests);

    return result.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  Future<int> update(ServiceRequest request) async {
    final db = await instance.database;

    return db.update(
      tableServiceRequests,
      request.toJson(),
      where: '${ServiceRequestFields.id} = ?',
      whereArgs: [request.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;

    return await db.delete(
      tableServiceRequests,
      where: '${ServiceRequestFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncServiceRequests(List<ServiceRequest> requests) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      for (final request in requests) {
        // Insert or update each service request individually
        await txn.insert(
          tableServiceRequests,
          request.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

const String tableServiceRequests = 'serviceRequests';

class ServiceRequestFields {
  static final List<String> values = [
    id, userId, clientName, serviceDescription, date, time, location, imagePath, isApproved, status, category, phoneNumber, email, technicianId
  ];

  static const String id = 'id'; // Ensure ID is correctly typed as String in the database.
  static const String userId = 'userId'; // New field for user ID
  static const String clientName = 'clientName';
  static const String serviceDescription = 'serviceDescription';
  static const String date = 'date';
  static const String time = 'time';
  static const String location = 'location';
  static const String imagePath = 'imagePath';
  static const String isApproved = 'isApproved';
  static const String status = 'status';
  static const String category = 'category';
  static const String phoneNumber = 'phoneNumber'; // New field for phone number
  static const String email = 'email'; // New field for email
  static const String technicianId = 'technicianId'; // New field for technician ID
}

// Ensure to modify the ServiceRequest class to handle the technicianId appropriately.
