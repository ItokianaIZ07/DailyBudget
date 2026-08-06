import 'package:sqflite/sqflite.dart';
import 'database_constants.dart';
import 'tables/category_table.dart';
import 'tables/expense_table.dart';
import 'tables/limit_table.dart';
import 'tables/appMetadata_table.dart';
import 'seeders/category_seeder.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();

  DatabaseService._();

  static DatabaseService get instance => _instance;

  Database? connexion;

  Future<void> initialize() async {
    await _openDatabase();

    // await _runMigrations();
  }

  Future<Database> _openDatabase() async {
    if (connexion != null) {
      return connexion!;
    }
    String databasePath = await getDatabasesPath();
    String path = '$databasePath/${DatabaseConstants.databaseName}';
    connexion = await openDatabase(
      path, 
      version: DatabaseConstants.version,
      onCreate: (db, version) async {
        await _createTables(db);
        await CategorySeeder.initialize(db);
      },
      onUpgrade: (db, oldVersion, newVersion) => {

      },
    );
    return connexion!;
  }

  Future<void> _createTables(Database database) async {
    await CategoryTable.createTable(database);
    await ExpenseTable.createTable(database);
    await LimitTable.createTable(database);
    await AppmetadataTable.createTable(database);
  }
}
