import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/errors.dart';

class Category {
  Server? myServer;
  List<Channel> channels = [];
  List<dynamic> permitted = [];

  Future<Map<String, dynamic>?> findCategory(server, category, Db db) async {
    var categories = db.collection('$server.categories');
    return await categories.findOne(where.eq('categoryName', category));
  }

  static Future<Category> setCategoryData(category, server, Db db) async {
    var categories = db.collection('$server:categories');
    Category newCategory = Category();
    final categoryDoc =
        await categories.findOne(where.eq('categoryName', category));

    Server sample = Server();
    await sample.setServerData(server, db);
    newCategory.myServer = await sample.findServer(server, db);
    newCategory.channels = categoryDoc?['channels'];
    newCategory.permitted = categoryDoc?['permitted'];
    return newCategory;
  }

  Future<void> createCategory(
      String server, String category, Db db, bool c, bool m, bool p) async {
    if (await Checks.serverExists(server, db)) {
      await db.createCollection('$server.categories');
      DbCollection categories = db.collection('$server.categories');
      permitted = await Checks.permittedList(c, m, p);
      final document = {
        'categoryName': category,
        'channelList': channels,
        'permittedRoles': permitted
      };
      await categories.insertOne(document..['_id'] = ObjectId().toHexString());
      print('Category $category added in Server $server');
    } else {
      ProcessError.ServerDoesNotExist(server);
    }
  }
}
