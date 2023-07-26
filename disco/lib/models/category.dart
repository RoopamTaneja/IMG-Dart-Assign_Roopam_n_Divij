import 'package:disco/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/errors.dart';

class Category {
  Server? myServer;
  List<Channel> channels = [];
  List<String> permittedRoles = [];
  List<String> permittedUsers = [];
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
    newCategory.myServer = (await sample.findServer(server, db)) as Server?;

    newCategory.channels = categoryDoc?['channels'];
    newCategory.permittedRoles = categoryDoc?['permitted'];
    return newCategory;
  }

  Future<void> createCategory(String server, String category, Db db, bool c,
      bool m, bool p, List userList) async {
    if (await Checks.serverExists(server, db)) {
      await db.createCollection('$server.categories');
      DbCollection categories = db.collection('$server.categories');
      permittedRoles = await Checks.permittedList(c, m, p);
      Server ser = Server();
      ser.setServerData(server, db);

      for (String i in userList) {
        if (permittedUsers.contains(i)) {
          continue;
        } else if (await Checks.userExists(i, db)) {
          User user = User();
          await user.setUserData(i, db);

          if (await Checks.isServerMember(user, ser, db)) {
            await categories.update(where.eq('categoryName', category),
                modify.push('permittedUsers', i));
            permittedUsers.add(i);
          } else {
            continue;
          }
        }
      }

      final document = {
        'categoryName': category,
        'channelList': channels,
        'permittedRoles': permittedRoles,
        'permittedUsers': permittedUsers
      };
      await categories.insertOne(document..['_id'] = ObjectId().toHexString());
      print('Category $category added in Server $server');
    } else {
      ProcessError.ServerDoesNotExist(server);
    }
  }
}
