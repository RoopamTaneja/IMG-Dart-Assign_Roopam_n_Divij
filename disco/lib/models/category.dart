import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';

class Category {
  Server? myServer;
  List<Channel> channels = [];
  List<String> permitted = [];

  Future? findCategory(category, Db db) async {
    var categories = db.collection('categories');
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
    ;
    newCategory.channels = categoryDoc?['channels'];
    newCategory.permitted = categoryDoc?['permitted'];
    return newCategory;
  }
}
