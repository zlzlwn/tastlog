import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tastelog_app/model/myrestaurant.dart';

/* 
    Description : local db viewmodel
    Author 		: Lcy
    Date 			: 2024.04.06
*/

class DatabaseHandler {

  Future<Database> initalizeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'restaurants.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE restaurants (seq integer primary key autoincrement, name text(30), phone text(30), lat numeric(20), long numeric(20), image blob, estimate text, initdate date)'
        );
      },
      version: 1,
    );
  }

  Future<List<MyRestaurants>> queryReview() async {
    final Database db = await initalizeDB();
    final List<Map<String, Object?>> result = await db.rawQuery('SELECT * FROM restaurants');

    return result.map((e) => MyRestaurants.fromMap(e)).toList();
  }

  Future<int> insertReview(MyRestaurants review) async {
    final Database db = await initalizeDB();
    int result;
    result = await db.rawInsert(
      'INSERT INTO restaurants '
      '(name,phone,lat,long,image,estimate,initdate) '
      'VALUES (?,?,?,?,?,?,?)',
      [review.name, review.phone, review.lat, review.long, review.image, review.estimate, review.initdate]
    );
    return result;
  }

  Future<int> updateReview(MyRestaurants review) async {
    final Database db = await initalizeDB();
    int result;
    result = await db.rawInsert(
      'UPDATE restaurants SET '
      'name=?, phone=?, lat=?, long=?, image=?, estimate=? '
      'WHERE seq=?',
      [review.name, review.phone, review.lat, review.long, review.image, review.estimate, review.seq]
    );
    return result;
  }

  Future<void> deleteReview(int? seq) async {
    final Database db = await initalizeDB();
    await db.rawDelete(
      'DELETE FROM restaurants '
      'WHERE seq = ?',
      [seq]
    );
  }

}