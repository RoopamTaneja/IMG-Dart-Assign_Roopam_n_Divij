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

  static Future<Category> setCategoryData(
      category, Server server, Db db) async {
    var categories = db.collection('categories');
    Category newCategory = Category();
    final categoryDoc =
        await categories.findOne(where.eq('categoryName', category));
    final categoryServer = categoryDoc?['ServerName'];
    Server sample = Server();
    await sample.setServerData(categoryServer, db);
    newCategory.myServer = sample;
    newCategory.channels = categoryDoc?['channels'];
    newCategory.permitted = categoryDoc?['permitted'];
    return newCategory;
  }
}
