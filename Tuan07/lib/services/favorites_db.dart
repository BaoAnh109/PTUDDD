import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Một tuyến đường yêu thích đã lưu.
class FavoriteRoute {
  final int? id;
  final String name;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String mode;
  final String distanceText;
  final String durationText;
  final String encodedPolyline;

  const FavoriteRoute({
    this.id,
    required this.name,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.mode,
    required this.distanceText,
    required this.durationText,
    required this.encodedPolyline,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'start_lat': startLat,
        'start_lng': startLng,
        'end_lat': endLat,
        'end_lng': endLng,
        'mode': mode,
        'distance_text': distanceText,
        'duration_text': durationText,
        'encoded_polyline': encodedPolyline,
      };

  factory FavoriteRoute.fromMap(Map<String, dynamic> m) => FavoriteRoute(
        id: m['id'] as int?,
        name: m['name'] as String,
        startLat: (m['start_lat'] as num).toDouble(),
        startLng: (m['start_lng'] as num).toDouble(),
        endLat: (m['end_lat'] as num).toDouble(),
        endLng: (m['end_lng'] as num).toDouble(),
        mode: m['mode'] as String,
        distanceText: m['distance_text'] as String,
        durationText: m['duration_text'] as String,
        encodedPolyline: m['encoded_polyline'] as String,
      );
}

/// Lưu / đọc danh sách tuyến đường yêu thích bằng SQLite.
class FavoritesDb {
  FavoritesDb._();
  static final FavoritesDb instance = FavoritesDb._();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'favorite_routes.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE favorite_routes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          start_lat REAL NOT NULL,
          start_lng REAL NOT NULL,
          end_lat REAL NOT NULL,
          end_lng REAL NOT NULL,
          mode TEXT NOT NULL,
          distance_text TEXT NOT NULL,
          duration_text TEXT NOT NULL,
          encoded_polyline TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  Future<int> insert(FavoriteRoute route) async {
    final db = await database;
    return db.insert('favorite_routes', route.toMap());
  }

  Future<List<FavoriteRoute>> getAll() async {
    final db = await database;
    final rows =
        await db.query('favorite_routes', orderBy: 'id DESC');
    return rows.map(FavoriteRoute.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('favorite_routes', where: 'id = ?', whereArgs: [id]);
  }
}
